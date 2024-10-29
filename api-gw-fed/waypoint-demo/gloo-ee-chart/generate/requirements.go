package generate

import (
	"github.com/pkg/errors"
)

// ChartRequirements represents the requirements.yaml file that is packaged in a Helm chart.
// During Chart generation, we start with a templated file, and then transform it to modify
// properties of certain dependencies. This allows us to point to local sub-charts during development
// ChartRequirements is self-contained so that a developer can perform any of the actions on the file that
// they need (reading, modifying, writing)
type ChartRequirements struct {
	SourceFile string
	DependencyList
}

type DependencyList struct {
	Dependencies []*Dependency `json:"dependencies"`
}

type Dependency struct {
	Name       string   `json:"name"`
	Version    string   `json:"version"`
	Repository string   `json:"repository"`
	Condition  string   `json:"condition,omitempty"`
	Tags       []string `json:"tags,omitempty"`
}

// NewChartRequirements accepts a source file that stores the requirements for a Helm chart
// It loads the requirements into memory, or panics if it is unable to do so
func NewChartRequirements(sourceFile string) *ChartRequirements {
	requirements := &ChartRequirements{
		SourceFile: sourceFile,
	}

	if err := requirements.loadDependencies(); err != nil {
		// This is running during local development (during Helm chart generation) and should never fail.
		// We intentionally produce a loud error here
		panic(errors.Wrapf(err, "Failed to load Chart requirements from: %s", sourceFile))
	}

	return requirements
}

func (r *ChartRequirements) loadDependencies() error {
	return readYaml(r.SourceFile, &r.DependencyList)
}

// GetVersionForDependency returns the version for a given dependency, or an empty string if the dependency is not listed
func (r *ChartRequirements) GetVersionForDependency(dependencyName string) string {
	for _, v := range r.Dependencies {
		if v.Name == dependencyName {
			return v.Version
		}
	}

	return ""
}

type DependencyTransform func(dependency *Dependency)

// TransformDependency modifies a particular dependency
func (r *ChartRequirements) TransformDependency(dependencyName string, transform DependencyTransform) {
	for _, v := range r.Dependencies {
		if v.Name == dependencyName {
			transform(v)
		}
	}
}

// WriteToHelm2Chart writes the existing dependencies to a specific location
// This is useful when using Helm2 Charts, because the requirements are maintained in a separate file.
// However, in Helm3, the dependencies are expressed
// within the Chart.yaml: https://helm.sh/docs/faq/changes_since_helm2/#consolidation-of-requirementsyaml-into-chartyaml
func (r *ChartRequirements) WriteToHelm2Chart() error {
	panic("Do not use. Prefer: ChartInformation.SetChartRequirements")
}
