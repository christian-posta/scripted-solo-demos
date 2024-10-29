package generate

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/ghodss/yaml"
	"github.com/pkg/errors"
	glooGenerate "github.com/solo-io/gloo/install/helm/gloo/generate"
	"github.com/solo-io/k8s-utils/installutils/helmchart"
)

const (
	glooFedDependencyName       = "gloo-fed"
	glooOsDependencyName        = "gloo"
	gatewayPortalDependencyName = "gateway-portal-web-server"
	glooOsModuleName            = "github.com/solo-io/gloo"
)

// GetGlooSubchartVersion returns the version of Gloo Open Source (ie 1.16.0) that we depend on
// Gloo Open Source is a sub-chart of Gloo Enterprise and we attempt to identify the appropriate version by:
//  1. Attempting to parse the requirements.yaml definition
//  2. Falling back to the go.mod definition
func GetGlooSubchartVersion(requirements *ChartRequirements) (string, error) {
	requirementVersion := requirements.GetVersionForDependency(glooOsDependencyName)
	if requirementVersion != "" {
		return requirementVersion, nil
	}

	return goModPackageVersion(glooOsModuleName)
}

func goModPackageVersion(moduleName string) (string, error) {
	cmd := exec.Command("go", "list", "-f", "'{{ .Version }}'", "-m", moduleName)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", err
	}
	cleanedOutput := strings.Trim(strings.TrimSpace(string(output)), "'")
	return strings.TrimPrefix(cleanedOutput, "v"), nil
}

func readYaml(path string, obj interface{}) error {
	bytes, err := os.ReadFile(path)
	if err != nil {
		return errors.Wrapf(err, "failed reading server config file: %s", path)
	}

	if err := yaml.Unmarshal(bytes, obj); err != nil {
		return errors.Wrap(err, "failed parsing configuration file")
	}

	return nil
}

func writeYaml(obj interface{}, path string) error {
	bytes, err := yaml.Marshal(obj)
	if err != nil {
		return errors.Wrapf(err, "failed marshaling config struct")
	}

	err = os.WriteFile(path, bytes, os.ModePerm)
	if err != nil {
		return errors.Wrapf(err, "failing writing config file")
	}
	return nil
}

func readConfig(path string) (HelmConfig, error) {
	var config HelmConfig
	if err := readYaml(path, &config); err != nil {
		return config, err
	}
	return config, nil
}

func transformChartRequirements(
	requirements *ChartRequirements,
	osGlooVersion string, glooEeVersion string, glooFedRepoOverride string, glooRepositoryOverride string,
) {
	requirements.TransformDependency(glooOsDependencyName, func(dependency *Dependency) {
		if glooRepositoryOverride != "" {
			fmt.Printf("overriding gloo repository with %v \n", glooRepositoryOverride)
			dependency.Repository = glooRepositoryOverride
		}

		if dependency.Version == "" {
			fmt.Printf("with version %v \n", osGlooVersion)
			dependency.Version = osGlooVersion
		}
	})

	requirements.TransformDependency(glooFedDependencyName, func(dependency *Dependency) {
		if glooFedRepoOverride != "" {
			dependency.Repository = glooFedRepoOverride
		}
		if dependency.Version == "" {
			dependency.Version = glooEeVersion
		}
	})

	requirements.TransformDependency(gatewayPortalDependencyName, func(dependency *Dependency) {
		if dependency.Version == "" {
			dependency.Version = glooEeVersion
		}
	})
}

func transformChartInformation(chartInformation *ChartInformation, chartVersion string, requirements *ChartRequirements) {
	chartInformation.SetVersion(chartVersion)
	chartInformation.SetChartDependencies(requirements)
}

func (gc *GenerationConfig) generateChartYaml(chartTemplate, chartOutput, chartVersion string) error {
	var chart glooGenerate.Chart
	if err := readYaml(chartTemplate, &chart); err != nil {
		return err
	}

	chart.Version = chartVersion

	return writeYaml(&chart, chartOutput)
}

func writeDocs(docs helmchart.HelmValues, path string) error {
	err := os.WriteFile(path, []byte(docs.ToMarkdown()), os.ModePerm)
	if err != nil {
		return errors.Wrapf(err, "failed writing helm values file")
	}
	return nil
}
