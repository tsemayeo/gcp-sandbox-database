output "user_credentials" {
  description = "All user credentials (username and password for each user)"
  value = {
    for user_key, user in module.users : user_key => {
      username = user.username
      password = user.password
    }
  }
  sensitive = true
}
