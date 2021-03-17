package main

import "html/template"

const (
	pageContent = `<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="shortcut icon" type="image/x-icon" href="/resources/images/favicon.png">
    <title>PetClinic :: a Spring Framework demonstration</title>

    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

    <link rel="stylesheet" href="/resources/css/petclinic.css"/>
  </head>
  <body>
  <nav class="navbar navbar-default" role="navigation">
      <div class="container">
          <div class="navbar-header">
              <a class="navbar-brand" href="/"><span></span></a>
              <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#main-navbar">
                  <span class="sr-only"><os-p>Toggle navigation</os-p></span>
                  <span class="icon-bar"></span>
                  <span class="icon-bar"></span>
                  <span class="icon-bar"></span>
              </button>
          </div>
          <div class="navbar-collapse collapse" id="main-navbar">
              <ul class="nav navbar-nav navbar-right">
  
                  <li>
                      <a href="">
                        <span class="glyphicon  glyphicon-null" aria-hidden="true"></span>
                        <span></span>
                      </a>
                  </li>
  
                  <li>
                      <a href="/" title="home page">
                        <span class="glyphicon  glyphicon-home" aria-hidden="true"></span>
                        <span>Home</span>
                      </a>
                  </li>
  
                  <li>
                      <a href="/owners/find" title="find owners">
                        <span class="glyphicon  glyphicon-search" aria-hidden="true"></span>
                        <span>Find owners</span>
                      </a>
                  </li>
  
                  <li class="active">
                      <a href="/vets.html" title="veterinarians">
                        <span class="glyphicon  glyphicon-th-list" aria-hidden="true"></span>
                        <span>Veterinarians</span>
                      </a>
                  </li>
  
                  <li>
                  <a href="/contact.html" title="contact">
                    <span class="glyphicon  glyphicon-envelope" aria-hidden="true"></span>
                    <span>Contact</span>
                  </a>
                  </li>

                  <li>
                      <a href="/oups" title="trigger a RuntimeException to see how it is handled">
                        <span class="glyphicon  glyphicon-warning-sign" aria-hidden="true"></span>
                        <span>Error</span>
                      </a>
                  </li>
  
              </ul>
          </div>
      </div>
  </nav>
  <div class="container-fluid">
	  <div class="container xd-container">
	  
    <h2>Veterinarians</h2>
	  <table id="vets" class="table table-striped">
		<thead>
		  <tr>
			<th>Name</th>
			<th>City</th>
			<th>Specialties</th>
		  </tr>
		</thead>
		<tbody>	
		{{ range . }}
		  <tr>
			<td>{{ .FirstName }} {{ .LastName }}</td>
			<td>{{ .City }}</td>
			<td>{{range .Specialties }}
			<span>{{ . }}</span>
			{{else}}
			<span>none</span>
			{{end}}</td>
		  </tr>
		{{end}}
		</tbody>
	  </table>
  
    <div class="row">
    <a class="btn btn-default" href="/vets/new">Add Veterinarian</a>
    </div>

	<table class="table-buttons">
		<tr>
		  <td><a href="/vets.xml">View as XML</a></td>
		  <td><a href="/vets.json">View as JSON</a></td>
		</tr>
	</table>

	<br/>
        <div class="container">
          <div class="row">
            <div class="col-12 text-center">
			  Modified by gloo&trade;
			</div>
          </div>
        </div>
      </div>
  </div>
	
  <script src="/webjars/jquery/2.2.4/jquery.min.js"></script>
  <script src="/webjars/jquery-ui/1.11.4/jquery-ui.min.js"></script>
  <script src="/webjars/bootstrap/3.3.6/js/bootstrap.min.js"></script>

  </body>
</html>`

	formContent = `<!DOCTYPE html>
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link rel="shortcut icon" type="image/x-icon" href="/resources/images/favicon.png">
      <title>PetClinic :: a Spring Framework demonstration</title>
  
      <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
      <![endif]-->
  
      <link rel="stylesheet" href="/resources/css/petclinic.css"/>
    </head>
    <body>
    <nav class="navbar navbar-default" role="navigation">
        <div class="container">
            <div class="navbar-header">
                <a class="navbar-brand" href="/"><span></span></a>
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#main-navbar">
                    <span class="sr-only"><os-p>Toggle navigation</os-p></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
            </div>
            <div class="navbar-collapse collapse" id="main-navbar">
                <ul class="nav navbar-nav navbar-right">
    
                    <li>
                        <a href="">
                          <span class="glyphicon  glyphicon-null" aria-hidden="true"></span>
                          <span></span>
                        </a>
                    </li>
    
                    <li>
                        <a href="/" title="home page">
                          <span class="glyphicon  glyphicon-home" aria-hidden="true"></span>
                          <span>Home</span>
                        </a>
                    </li>
    
                    <li>
                        <a href="/owners/find" title="find owners">
                          <span class="glyphicon  glyphicon-search" aria-hidden="true"></span>
                          <span>Find owners</span>
                        </a>
                    </li>
    
                    <li class="active">
                        <a href="/vets.html" title="veterinarians">
                          <span class="glyphicon  glyphicon-th-list" aria-hidden="true"></span>
                          <span>Veterinarians</span>
                        </a>
                    </li>
    
                    <li>
                    <a href="/contact.html" title="contact">
                      <span class="glyphicon  glyphicon-envelope" aria-hidden="true"></span>
                      <span>Contact</span>
                    </a>
                    </li>
  
                    <li>
                        <a href="/oups" title="trigger a RuntimeException to see how it is handled">
                          <span class="glyphicon  glyphicon-warning-sign" aria-hidden="true"></span>
                          <span>Error</span>
                        </a>
                    </li>
    
                </ul>
            </div>
        </div>
    </nav>
    <div class="container-fluid">
      <div class="container xd-container">
      
      <h2>New Vet</h2>
      <form class="form-horizontal" id="add-vet-form" method="post" action="/vets/new">
        <div class="form-group">
            <div class="form-group">
                <label class="col-sm-2 control-label" for="firstName">First Name</label>
                <div class="col-sm-10">
                <input type="text" class="form-control" name="firstName" id="firstName" placeholder="First Name"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-2 control-label" for="lastName">Last Name</label>
                <div class="col-sm-10">
                <input type="text" class="form-control" name="lastName" id="lastName" placeholder="Last Name"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-2 control-label" for="city">City</label>
                <div class="col-sm-10">
                <input type="text" class="form-control" name="city" id="city" placeholder="City"/>
                </div>
            </div>
        </div>
        <div class="form-group">
          <div class="col-sm-offset-2 col-sm-10">
              <button class="btn btn-default" type="submit">Add Vet</button>
          </div>
        </div>
      </form>

    <br/>
          <div class="container">
            <div class="row">
              <div class="col-12 text-center">
          Modified by gloo&trade;
        </div>
            </div>
          </div>
        </div>
    </div>
    
    <script src="/webjars/jquery/2.2.4/jquery.min.js"></script>
    <script src="/webjars/jquery-ui/1.11.4/jquery-ui.min.js"></script>
    <script src="/webjars/bootstrap/3.3.6/js/bootstrap.min.js"></script>
  
    </body>
  </html>`
)

var (
	pageTemplate = template.Must(template.New("vets").Parse(pageContent))
	formTemplate = template.Must(template.New("form").Parse(formContent))
)
