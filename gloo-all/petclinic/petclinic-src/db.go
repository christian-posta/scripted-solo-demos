package main

import (
	"database/sql"
	"fmt"
	"os"
	"sort"

	_ "github.com/go-sql-driver/mysql"
)

const (
	dbUser     = "root"
	dbPassword = "petclinic"
	dbHost     = "petclinic-db.default.svc.cluster.local"
	dbName     = "petclinic"

	query = `SELECT first_name, last_name, city, name
FROM vets
LEFT JOIN vet_specialties vs ON vets.id = vs.vet_id
LEFT JOIN specialties s ON s.id = vs.specialty_id`
)

type Vet struct {
	FirstName   string
	LastName    string
	City        string
	Specialties []string
}

func env(key, defaultValue string) string {
	v := os.Getenv(key)
	if v != "" {
		return v
	}
	return defaultValue
}

func connection() string {
	return fmt.Sprintf("%s:%s@tcp(%s:3306)/%s",
		env("DB_USER", dbUser),
		env("DB_PASSWORD", dbPassword),
		env("DB_HOST", dbHost),
		env("DB_NAME", dbName))
}

func vets() ([]*Vet, error) {
	db, err := sql.Open("mysql", connection())
	if err != nil {
		return nil, err
	}
	defer db.Close()

	stmt, err := db.Prepare(query)
	if err != nil {
		return nil, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	m := make(map[string]*Vet)
	for rows.Next() {
		vet := Vet{}
		var specialty sql.NullString
		var city sql.NullString
		if err := rows.Scan(&vet.FirstName, &vet.LastName, &city, &specialty); err != nil {
			return nil, err
		}
		key := vet.FirstName + ":" + vet.LastName
		if _, exists := m[key]; !exists {
			m[key] = &vet
		}
		if city.Valid {
			m[key].City = city.String
		}
		if specialty.Valid {
			m[key].Specialties = append(m[key].Specialties, specialty.String)
		}
	}

	err = rows.Err()
	if err != nil {
		return nil, err
	}

	vets := make([]*Vet, len(m))
	i := 0
	for _, v := range m {
		vets[i] = v
		i++
	}
	sort.SliceStable(vets, func(i int, j int) bool {
		l := vets[i].FirstName + " " + vets[i].LastName
		r := vets[j].FirstName + " " + vets[j].LastName
		return l < r
	})
	return vets, nil
}
