package generate

import (
	"os"

	"github.com/ghodss/yaml"
	errors "github.com/rotisserie/eris"
	glooGenerate "github.com/solo-io/gloo/install/helm/gloo/generate"
)

// ChartInformation represents the Chart.yaml file that is packaged in a Helm 3 chart.
// During Chart generation, we start with a templated file, and then transform it to modify certain
// properties
type ChartInformation struct {
	SourceFile string

	Chart Helm3ChartInformation
}

// Helm3ChartInformation contains the data that is contained in the Chart.yaml file
type Helm3ChartInformation struct {
	glooGenerate.Chart
	DependencyList
}

// NewChartInformation accepts a source file that stores the information for a Helm chart
// It loads the information into memory, or panics if it is unable to do so
func NewChartInformation(sourceFile string) *ChartInformation {
	information := &ChartInformation{
		SourceFile: sourceFile,
	}

	if err := information.loadInformation(); err != nil {
		// This is running during local development (during Helm chart generation) and should never fail.
		// We intentionally produce a loud error here
		panic(errors.Wrapf(err, "Failed to load Chart information from: %s", sourceFile))
	}

	return information
}

func (i *ChartInformation) loadInformation() error {
	return readYaml(i.SourceFile, &i.Chart)
}

func (i *ChartInformation) SetVersion(version string) {
	i.Chart.Version = version
}

// SetChartDependencies updates the dependencies of the Chart.
// This is new as of Helm3, see https://helm.sh/docs/faq/changes_since_helm2/#consolidation-of-requirementsyaml-into-chartyaml
// for how dependencies were previously managed
func (i *ChartInformation) SetChartDependencies(requirements *ChartRequirements) {
	i.Chart.DependencyList = requirements.DependencyList
}

func (i *ChartInformation) WriteToFile(filePath string) error {
	bytes, err := yaml.Marshal(&i.Chart)
	if err != nil {
		return errors.Wrapf(err, "failed marshaling config struct")
	}

	err = os.WriteFile(filePath, bytes, os.ModePerm)
	if err != nil {
		return errors.Wrapf(err, "failing writing config file")
	}
	return nil
}
