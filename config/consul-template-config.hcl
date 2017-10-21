exec {
  command = "gitea web --config /gitea/config/app.ini"
}

template {
  source      = "/gitea/config/app.ini.ctmpl"
  destination = "/gitea/config/app.ini"
}
