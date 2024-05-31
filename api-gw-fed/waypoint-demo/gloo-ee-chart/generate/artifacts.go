package generate

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"reflect"
	"strings"

	"github.com/solo-io/gloo-mesh-enterprise/v2/codegen/helm/platform"
	"github.com/solo-io/skv2/codegen"
	"github.com/solo-io/skv2/codegen/model"

	"github.com/solo-io/go-utils/stringutils"

	"github.com/solo-io/gloo/install/helm/gloo/generate"

	flag "github.com/spf13/pflag"
	v1 "k8s.io/api/core/v1"

	"github.com/pkg/errors"
	"github.com/solo-io/go-utils/log"
	"github.com/solo-io/k8s-utils/installutils/helmchart"
)

const (
	devPullPolicy          = string(v1.PullAlways)
	distributionPullPolicy = string(v1.PullIfNotPresent)
	defaultImageRegistry   = "quay.io/solo-io"
	gatewayPortalName      = "gateway-portal-web-server"
)

var (
	// fipsSupportedImages is a list of images that support a FIPS compliant variant
	// https://github.com/solo-io/solo-projects/pull/4178#discussion_r997195217
	// This is not the ideal way of managing our set of FIPS images, and some preferred alternatives are:
	// 1. Ensure all images are FIPS compliant
	// 2. Derive the values from the Gloo sub-chart
	fipsSupportedImages = []string{
		"gloo-ee",
		"extauth-ee",
		"gloo-ee-envoy-wrapper",
		"rate-limit-ee",
		"ext-auth-plugins",
		"discovery-ee",
		"sds-ee",
	}
)

// We produce two helm artifacts: GlooE and Gloo with a read-only version of the GlooE UI

// these arguments are provided on the command line during make or CI. They are shared by all artifacts
type GenerationArguments struct {
	Version string
	// Allows for overriding the global image registry
	RepoPrefixOverride string
	// Allows for overriding the gloo-fed chart repo; used in local builds to specify a
	// local directory instead of the official gloo-fed-helm release repository.
	GlooFedRepoOverride string

	// Allows for overriding the gloo chart repo; used for alternate deployment patterns
	// such as consuming a gloo chart which was pushed to a test helm repo
	GlooRepoOverride string
	GenerateHelmDocs bool

	// specify using image digests, rather than image tags
	UseDigests bool
}

// GenerationConfig represents all the artifact-specific config
type GenerationConfig struct {
	Arguments       *GenerationArguments
	OsGlooVersion   string
	GenerationFiles *GenerationFiles
	// override the global image Pull Policy of the helm chart
	PullPolicyForVersion string
	// if running arm, and not using Generation Arguments RepoPrefixOverride,
	// this will set the registry for all images if the architecture is arm
	ArmImageRegistry string

	// ChartRequirements contains the contents of requirements.yaml file
	ChartRequirements *ChartRequirements

	// ChartInformation contains the contents of chart.yaml file
	ChartInformation *ChartInformation
}

// GenerationFiles specify the files read or created while producing a given artifact
type GenerationFiles struct {
	// not a file, just a way of identifying the purpose of the fileset
	Artifact             Artifact
	ValuesTemplate       string
	ValuesOutput         string
	DocsOutput           string
	ChartTemplate        string
	ChartOutput          string
	RequirementsTemplate string
	RequirementsOutput   string
}

type Artifact int

const (
	GlooE Artifact = iota
)

func ArtifactName(artifact Artifact) string {
	switch artifact {
	case GlooE:
		return "GlooE"
	default:
		return "unknown artifact"
	}
}

// Run is the entrypoint for the Gloo Edge Enterprise Helm Chart generation
// It accepts:
//
//	GenerationArguments: A set of user-defined overrides for constructing the chart
//	GenerationFiles: A set of input templates and output file locations
//
// Run works like an E(xtract) T(transform) L(oad) pipeline: It reads the template files,
// transforms them, and loads them into the output file destinations. These generated files
// are then packaged as a Helm chart and published as a release artifact
func Run(args *GenerationArguments, generationFiles *GenerationFiles) error {
	// 1. Load the Helm Chart information
	chartInformation := NewChartInformation(generationFiles.ChartTemplate)

	// 2. Load the Helm Chart requirements
	chartRequirements := NewChartRequirements(generationFiles.RequirementsTemplate)

	// 3. Identify the version of Gloo Open Source
	openSourceGlooVersion, err := getOpenSourceGlooVersion(args, chartRequirements)
	if err != nil {
		return errors.Wrapf(err, "failed to determine open source Gloo version")
	}
	log.Printf("Open source gloo version is: %v", openSourceGlooVersion)

	// 4. Prepare the GenerationConfig, which is the full set of inputs that are used by Chart generation
	genConfig := GetGenerationConfig(args, openSourceGlooVersion, generationFiles)
	genConfig.ChartRequirements = chartRequirements
	genConfig.ChartInformation = chartInformation

	// 5. Perform the Chart generation
	return genConfig.runGeneration()
}

func getOpenSourceGlooVersion(args *GenerationArguments, chartRequirements *ChartRequirements) (string, error) {
	if args.GlooRepoOverride != "" {
		// in the event we provide a glooRepoOverride, we want to use an identical version of gloo and gloo-ee
		return args.Version, nil
	}
	return GetGlooSubchartVersion(chartRequirements)
}

func GetGenerationConfig(args *GenerationArguments, osGlooVersion string, generationFiles *GenerationFiles) *GenerationConfig {
	pullPolicyForVersion := distributionPullPolicy
	if args.Version == "dev" {
		pullPolicyForVersion = devPullPolicy
	}

	return &GenerationConfig{
		Arguments:            args,
		OsGlooVersion:        osGlooVersion,
		PullPolicyForVersion: pullPolicyForVersion,
		GenerationFiles:      generationFiles,
		ArmImageRegistry:     args.RepoPrefixOverride,
	}
}

func GetArguments(args *GenerationArguments) error {
	if len(os.Args) < 2 {
		return errors.New("Must provide version as argument")
	} else {
		args.Version = os.Args[1]
	}

	// Parse optional arguments
	var repoPrefixOverride = flag.String(
		"repo-prefix-override",
		"",
		"(Optional) repository prefix override.")
	var glooFedRepoOverride = flag.String(
		"gloo-fed-repo-override",
		"",
		"(Optional) repository override for gloo-fed chart.")
	var glooRepoOverride = flag.String(
		"gloo-repo-override",
		"",
		"(Optional) repository override for gloo chart.")
	var generateHelmDocs = flag.Bool(
		"generate-helm-docs",
		false,
		"(Optional) if set, will generate docs for the helm values")
	var useDigests = flag.Bool(
		"use-digests",
		false,
		"(Optional) specify using image digests, rather than image tags",
	)
	flag.Parse()

	if *repoPrefixOverride != "" {
		args.RepoPrefixOverride = *repoPrefixOverride
	}
	if *glooFedRepoOverride != "" {
		args.GlooFedRepoOverride = *glooFedRepoOverride
	}
	if *glooRepoOverride != "" {
		args.GlooRepoOverride = *glooRepoOverride
	}
	if *generateHelmDocs {
		args.GenerateHelmDocs = *generateHelmDocs
	}
	if *useDigests {
		args.UseDigests = *useDigests
	}
	return nil
}

func (gc *GenerationConfig) runGeneration() error {
	log.Printf("Generating files for Enterprise Helm Chart.")
	config, err := gc.generateValuesYamls()
	if err != nil {
		return errors.Wrapf(err, "generating values.yaml failed")
	}

	// generating the gateway portal chart
	if err := genGatewayPortalChart(config); err != nil {
		return errors.Wrapf(err, "generating gateway portal chart failed")
	}

	transformChartRequirements(
		gc.ChartRequirements,
		gc.OsGlooVersion,
		gc.Arguments.Version,
		gc.Arguments.GlooFedRepoOverride,
		gc.Arguments.GlooRepoOverride)

	transformChartInformation(
		gc.ChartInformation,
		gc.Arguments.Version,
		gc.ChartRequirements)

	if err := gc.ChartInformation.WriteToFile(gc.GenerationFiles.ChartOutput); err != nil {
		return errors.Wrapf(err, "unable to write Chart.yaml")
	}

	if gc.Arguments.GenerateHelmDocs {
		log.Printf("Generating helm value docs in file: %v", gc.GenerationFiles.DocsOutput)
		if err := gc.generateValueDocs(); err != nil {
			return errors.Wrapf(err, "Generating values.txt failed")
		}
	}
	return nil
}

func (gc *GenerationConfig) generateValuesYamls() (*HelmConfig, error) {
	switch gc.GenerationFiles.Artifact {
	case GlooE:
		return gc.generateValuesYamlForGlooE()
	default:
		return nil, errors.New("unknown artifact specified")
	}
}

////////////////////////////////////////////////////////////////////////////////
// generate Gloo-ee values file
////////////////////////////////////////////////////////////////////////////////

func (gc *GenerationConfig) generateValuesConfig(versionOverride string) (*HelmConfig, error) {
	config, err := readConfig(gc.GenerationFiles.ValuesTemplate)
	if err != nil {
		return nil, err
	}

	glooEeVersion := &gc.Arguments.Version
	if versionOverride != "" {
		glooEeVersion = &versionOverride
	}
	glooOssTag := &gc.OsGlooVersion
	if glooOssTag == nil {
		glooOssTag = glooEeVersion
	}
	config.Gloo.Gloo.Deployment.OssImageTag = glooOssTag
	config.Gloo.Gloo.Deployment.Image.Tag = glooEeVersion
	for _, v := range config.Gloo.GatewayProxies {
		v.PodTemplate.Image.Tag = glooEeVersion
	}
	if config.Gloo.IngressProxy != nil {
		config.Gloo.IngressProxy.Deployment.Image.Tag = glooEeVersion
	}
	config.Gloo.Settings.Integrations.Knative.Proxy.Image.Tag = glooEeVersion
	// Use open source gloo version for discovery and gateway

	// This code used to assume that all relavant structs were already instantiated.
	// But since we no longer duplicate certain most values between the OS and enterprise
	// values-template.yaml file, we need to nil check and create several values that
	// are no longer present in the default enterprise values-template.
	if config.Gloo.Discovery == nil {
		config.Gloo.Discovery = &generate.Discovery{}
	}
	if config.Gloo.Discovery.Deployment == nil {
		config.Gloo.Discovery.Deployment = &generate.DiscoveryDeployment{}
	}
	config.Gloo.Discovery.Deployment.Image.Tag = glooEeVersion

	if config.Gloo.Gateway == nil {
		config.Gloo.Gateway = &generate.Gateway{}
	}

	if config.Gloo.Gateway.CertGenJob == nil {
		config.Gloo.Gateway.CertGenJob = &generate.CertGenJob{}
	}
	if config.Gloo.Gateway.CertGenJob.Image == nil {
		config.Gloo.Gateway.CertGenJob.Image = &generate.Image{}
	}
	config.Gloo.Gateway.CertGenJob.Image.Tag = glooOssTag

	if config.Gloo.Gateway.RolloutJob == nil {
		config.Gloo.Gateway.RolloutJob = &generate.RolloutJob{}
	}
	if config.Gloo.Gateway.RolloutJob.Image == nil {
		config.Gloo.Gateway.RolloutJob.Image = &generate.Image{}
	}
	config.Gloo.Gateway.RolloutJob.Image.Tag = glooOssTag

	if config.Gloo.Gateway.CleanupJob == nil {
		config.Gloo.Gateway.CleanupJob = &generate.CleanupJob{}
	}
	if config.Gloo.Gateway.CleanupJob.Image == nil {
		config.Gloo.Gateway.CleanupJob.Image = &generate.Image{}
	}
	config.Gloo.Gateway.CleanupJob.Image.Tag = glooOssTag

	config.Observability.Deployment.Image.Tag = glooEeVersion

	if config.Global.GlooMtls.Sds.Image == nil {
		config.Global.GlooMtls.Sds.Image = &generate.Image{}
	}
	config.Global.GlooMtls.Sds.Image.Tag = glooEeVersion
	config.Global.GlooMtls.EnvoySidecar.Image.Tag = glooEeVersion

	pullPolicy := gc.PullPolicyForVersion
	config.Gloo.Gloo.Deployment.Image.PullPolicy = &pullPolicy
	for _, v := range config.Gloo.GatewayProxies {
		v.PodTemplate.Image.PullPolicy = &pullPolicy
	}
	if config.Gloo.IngressProxy != nil {
		config.Gloo.IngressProxy.Deployment.Image.PullPolicy = &pullPolicy
	}

	config.Gloo.Settings.Integrations.Knative.Proxy.Image.PullPolicy = &pullPolicy
	config.Gloo.Discovery.Deployment.Image.PullPolicy = &pullPolicy
	config.Gloo.Gateway.CertGenJob.Image.PullPolicy = &pullPolicy
	config.Gloo.Gateway.RolloutJob.Image.PullPolicy = &pullPolicy
	config.Gloo.Gateway.CleanupJob.Image.PullPolicy = &pullPolicy
	config.Observability.Deployment.Image.PullPolicy = &pullPolicy
	config.Redis.Deployment.Image.PullPolicy = &pullPolicy

	updateExtensionsImageVersionAndPullPolicy(config, pullPolicy, glooEeVersion)

	if gc.Arguments.RepoPrefixOverride != "" {
		config.Global.Image.Registry = &gc.Arguments.RepoPrefixOverride
	} else if gc.ArmImageRegistry != "" {
		// assumes that if running arm, client wants registry to be default registry AKA (quay.io)
		// for the below images
		config.Global.Image.Registry = &gc.ArmImageRegistry
		gtw := config.Gloo.Gateway
		dir := defaultImageRegistry
		gtw.CertGenJob.Image.Registry = &dir
		gtw.RolloutJob.Image.Registry = &dir
		gtw.CleanupJob.Image.Registry = &dir
		config.Global.GlooMtls.Sds.Image.Registry = &dir
	}

	if gc.Arguments.UseDigests {
		return gc.convertAllTagsToDigests(config), nil
	}
	return &config, nil
}

func (gc *GenerationConfig) convertAllTagsToDigests(config HelmConfig) *HelmConfig {
	// "intelligently" process all nested structs of structs
	for _, imagePath := range gc.findImagePaths(config) {
		// extract image object coresponding to imagePath
		if !canUseFieldByIndex(reflect.ValueOf(config), imagePath) {
			continue // fields _above_ "Image" are nil
		}

		img := reflect.ValueOf(config).FieldByIndex(imagePath).Interface().(*generate.Image)
		if img == nil || img.Tag == nil || img.Repository == nil {
			continue // "Image" is nil
		}

		setDigest(img, config)
	}

	// handle special cases
	for _, v := range config.Gloo.GatewayProxies { // <--- "list of structs" != "struct of struct" assumptions
		setDigest(v.PodTemplate.Image, config)
	}

	return &config
}

func (gc *GenerationConfig) findImagePaths(config HelmConfig) [][]int {
	// to start, we have 2 top-level fields to search: Config and GlobalConfig
	fieldPaths := [][]int{{0}, {1}}   // collector object; in-progress field paths stored here
	imagePaths := [][]int{}           // collector object; matched "Image" field paths stored here
	var curPath []int                 // currently-considered field path.  Ex:  {0,0,0} --> config.Config.Settings.WatchNamespaces
	tConfig := reflect.TypeOf(config) // top level config type
	var cConfig reflect.Type          // current field type

	// DFS for all paths with an "Image" field
	for len(fieldPaths) > 0 {
		// pop oldest-added subpath
		curPath, fieldPaths = fieldPaths[0], fieldPaths[1:]
		cConfig = tConfig.FieldByIndex(curPath).Type
		if cConfig.Kind() == reflect.Ptr {
			cConfig = cConfig.Elem()
		}

		if cConfig.Name() == "Image" {
			// found an image to overwrite
			imagePaths = append(imagePaths, curPath)
			continue
		} else if cConfig.Kind() != reflect.Struct {
			// We have delved too greedily and too deep.  Turn back
			continue
		}

		// add newly-discovered fields to collector
		for i := range cConfig.NumField() {
			tmp := make([]int, len(curPath))
			copy(tmp, curPath) // copy op needed to prevent mutation of earlier added items to fieldPaths
			fieldPaths = append(fieldPaths, append(tmp, i))
		}
	}
	return imagePaths
}

func setDigest(img *generate.Image, config HelmConfig) {
	registry := config.Global.Image.Registry
	if img.Registry != nil {
		registry = img.Registry
	}
	imageUrl := *registry + "/" + *img.Repository + ":" + *img.Tag

	digest, _, _ := ShellOut("docker manifest inspect " + imageUrl + " -v | jq -r \".Descriptor.digest\"")
	digest = strings.TrimSpace(digest)
	if digest != "" {
		// notably, non-solo-produced images are ignored, here.  Though not exhaustively true, many of them
		// don't have a _single_ digest.  Rather, they have several, on a per-platform basis.
		img.Digest = &digest
	}

	// FIPS exceptions pulled from "gloo.image": https://github.com/solo-io/gloo/blob/main/install/helm/gloo/templates/_helpers.tpl#L22-L24
	imageName := *img.Repository
	if stringutils.ContainsString(imageName, fipsSupportedImages) {
		fipsUrl := *registry + "/" + imageName + "-fips:" + *img.Tag
		digest, _, _ := ShellOut("docker manifest inspect " + fipsUrl + " -v | jq -r \".Descriptor.digest\"")
		digest = strings.TrimSpace(digest)
		if digest != "" {
			// notably, non-solo-produced images are ignored, here.  Though not exhaustively true, many of them
			// don't have a _single_ digest.  Rather, they have several, on a per-platform basis.
			img.FipsDigest = &digest
		}

	}
}

func ShellOut(command string) (string, string, error) {
	var stdout bytes.Buffer
	var stderr bytes.Buffer
	cmd := exec.Command("bash", "-c", command)
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	return stdout.String(), stderr.String(), err
}

func canUseFieldByIndex(v reflect.Value, index []int) bool {
	// stolen/lightly modified from reflect.FieldByIndex.  For our use case, we don't want to panic
	// on a v.IsNil().  Rather, we want to abort our computation
	if len(index) == 1 {
		return true
	}
	for i, x := range index {
		if i > 0 {
			if v.Kind() == reflect.Pointer {
				if v.IsNil() {
					return false
				}
				v = v.Elem()
			}
		}
		v = v.Field(x)
	}
	return true
}

func (gc *GenerationConfig) generateValuesYamlForGlooE() (*HelmConfig, error) {
	config, err := gc.generateValuesConfig("")
	if err != nil {
		return nil, errors.Wrapf(err, "Unable to generate values config")
	}

	if err := writeYaml(config, gc.GenerationFiles.ValuesOutput); err != nil {
		return nil, errors.Wrapf(err, "unable to generate GlooE")
	}
	return config, nil
}

func (gc *GenerationConfig) generateValueDocs() error {
	// Overwrite the literal version with a description of the field value
	config, err := gc.generateValuesConfig("Version number, ex. 1.8.0")
	if err != nil {
		return errors.Wrapf(err, "Unable to generate values config")
	}
	return writeDocs(helmchart.Doc(config), gc.GenerationFiles.DocsOutput)
}

func updateExtensionsImageVersionAndPullPolicy(config HelmConfig, pullPolicy string, version *string) {
	// Extauth and rate-limit are both referenced in Values.gloo.settings, and thus need to be retro-typed
	// to avoid type-leakage into gloo-OS. Because helm like re-typing values defined in imported charts,
	// we must also place these in the shared `.Values.global.` struct.
	// The following code simply applies the version/pull policy cohesion that generateValuesYamlForGlooE() does
	// for everything else.

	config.Global.Extensions.ExtAuth.Deployment.Image.Tag = version
	config.Global.Extensions.ExtAuth.Deployment.Image.PullPolicy = &pullPolicy

	config.Global.Extensions.RateLimit.Deployment.Image.Tag = version
	config.Global.Extensions.RateLimit.Deployment.Image.PullPolicy = &pullPolicy

	config.Global.Extensions.Caching.Deployment.Image.Tag = version
	config.Global.Extensions.Caching.Deployment.Image.PullPolicy = &pullPolicy
}

// //////////////////////////////////////////////////////////////////////////////
// Generate Gateway Portal sub-chart
// //////////////////////////////////////////////////////////////////////////////

// Utilizes the go mod cache to copy files from gloo-mesh-enterprise/v2.
func getMeshResourceCmd(from, to string) string {
	goListCmd := "go list -m -f '{{ .Dir }}' \"github.com/solo-io/gloo-mesh-enterprise/v2\""
	return fmt.Sprintf("cp $(%s)/%s %s && chmod +w %s", goListCmd, from, to, to)
}

// Prepares the Portal operator used to generate the sub-chart's resources based on configuration previously set up when
// generating the parent chart (GlooEE). This allows us to use the same version tag and registry.
func preparePortalOperator(glooEeVersion string, config *HelmConfig) model.Operator {
	portalOperator := platform.PortalOperator()
	portalOperator.Name = gatewayPortalName

	imageRegistry := defaultImageRegistry
	if config.Global.Image.Registry != nil {
		imageRegistry = *config.Global.Image.Registry
	}
	portalOperator.Deployment.Image = model.Image{
		Repository: gatewayPortalName + "-ee", // the docker commands in makefile + releases have an "-ee" postfix
		Tag:        glooEeVersion,
		Registry:   imageRegistry,
	}
	return portalOperator
}

func copyPortalCrdTemplates(outTemplatePath string) error {
	// We set up the CRD templates in the sub-chart for UX purposes.
	// There is a Helm value (`installEnterpriseCrds`) which is used to install the Platform/Portal-related CRDs.
	// This would be confusing if on the root chart because it could be interpreted as necessary to get GlooEE CRDs.
	glooPlatformCrdsPath := "install/helm/gloo-platform-crds/templates"

	// for portal resources
	apiManagementTemplateName := "apimanagement.gloo.solo.io_crds.yaml"
	_, _, err := ShellOut(getMeshResourceCmd(
		filepath.Join(glooPlatformCrdsPath, apiManagementTemplateName),
		filepath.Join(outTemplatePath, apiManagementTemplateName),
	))
	if err != nil {
		return err
	}

	// for PortalConfig
	internalTemplateName := "internal.gloo.solo.io_crds.yaml"
	_, _, err = ShellOut(getMeshResourceCmd(
		filepath.Join(glooPlatformCrdsPath, internalTemplateName),
		filepath.Join(outTemplatePath, internalTemplateName),
	))
	return err
}

func genGatewayPortalChart(config *HelmConfig) error {
	chartManifestRoot := fmt.Sprintf("install/helm/%s", gatewayPortalName)
	if err := os.RemoveAll(chartManifestRoot); err != nil {
		return err
	}

	glooEeVersion := *config.Config.Gloo.Gloo.Deployment.Image.Tag
	portalOperator := preparePortalOperator(glooEeVersion, config)
	codegenCmd := codegen.Command{
		AppName:      gatewayPortalName,
		ManifestRoot: chartManifestRoot,
		Chart: &model.Chart{
			Data: model.Data{
				ApiVersion:  "v2",
				Name:        gatewayPortalName,
				Description: "Helm chart for the Gateway Portal Web Server. Only installable as a sub-chart of Gloo Edge Enterprise.",
				Version:     glooEeVersion,
			},
			Operators: []model.Operator{
				portalOperator,
			},
			// We set the required values to run the portal server, these are used during the start of the server as arguments.
			// We could also use the default values used in GME (through platform.GlooPlatformChart.Values), but that sets up
			// more values than we care about, so we just set the necessary ones manually.
			Values: map[string]interface{}{
				"common": map[string]interface{}{
					"addonNamespace": "",    // this is a required field.
					"verbose":        false, // this is a fallback value when the portal component's 'verbose' value is not set.
					"devMode":        false, // this is a fallback value when the portal component's 'devMode' value is not set.
				},
			},
		},
	}
	if err := codegenCmd.Execute(); err != nil {
		return err
	}

	// The storage-config Secret is used to hash the API keys for the portal server, and we will probably move away
	// from this once we look into storage.
	// Portal requires this secret to exist or else it fails to start up.
	storageConfigTemplatePath := "install/helm/gloo-platform/templates/storage-config.yaml"
	portalSubchartTemplatesPath := filepath.Join(chartManifestRoot, "templates")
	_, _, err := ShellOut(getMeshResourceCmd(storageConfigTemplatePath, filepath.Join(portalSubchartTemplatesPath, "storage-config.yaml")))
	if err != nil {
		return err
	}

	return copyPortalCrdTemplates(portalSubchartTemplatesPath)
}
