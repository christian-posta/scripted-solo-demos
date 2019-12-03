// run this file in order to generate a kubernetes-YAML file for your project's top-level CRD
package main

import (
	"io/ioutil"
	"log"
	"path/filepath"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"sigs.k8s.io/yaml"

	"github.com/solo-io/autopilot/codegen/util"

	v1 "autorouter.example.io/pkg/apis/autoroutes/v1"
)

//go:generate go run create_cr_yaml.go

// TODO: modify this object and re-run the script in order to produce the output YAML file
var ExampleAutoRoute = &v1.AutoRoute{
	ObjectMeta: metav1.ObjectMeta{
		Name: "example",
	},
	TypeMeta: metav1.TypeMeta{
		Kind:       "AutoRoute",
		APIVersion: "examples.io/v1",
	},
	Spec: v1.AutoRouteSpec{
		// fill me in!
	},
}

// modify this string to change the output file path
var OutputFile = filepath.Join(util.MustGetThisDir(), "..", "deploy", "autoroute_example.yaml")

func main() {
	yam, err := yaml.Marshal(ExampleAutoRoute)
	if err != nil {
		log.Fatal(err)
	}

	err = ioutil.WriteFile(OutputFile, yam, 0644)
	if err != nil {
		log.Fatal(err)
	}
}
