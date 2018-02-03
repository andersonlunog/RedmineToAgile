# load the things we need
mongoose = require('mongoose')
bcrypt = require('bcrypt-nodejs')
Schema = mongoose.Schema
# define the schema for our user model
userSchema = new Schema
  name: String
  email: String
  password: String
  facebook:
    id: String
    token: String
  google:
    id: String
    token: String
# generating a hash

userSchema.methods.generateHash = (password) ->
  bcrypt.hashSync password, bcrypt.genSaltSync(8), null

# checking if password is valid

userSchema.methods.validPassword = (password) ->
  bcrypt.compareSync password, @password

# create the model for users and expose it to our app
module.exports = mongoose.model('User', userSchema)

# ---
# generated by js2coffee 2.2.0