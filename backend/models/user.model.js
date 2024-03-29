const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const userSchema = new mongoose.Schema({
  username: { type: String, required: true },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  profilePic: { type: String },
  password: { type: String, required: true },
  verificationCode: { type: String },
  isEmailVerified: { type: Boolean, default: false },
  resetToken: {
    type: String,
  },
  resetTokenExpiration: {
    type: Date,
  },
  fcmToken: {
    type: String,
  }
});

userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) {
    return next();
  }
  const hashedPassword = await bcrypt.hash(this.password, 10);
  this.password = hashedPassword;
  next();
});

const User = mongoose.model("User", userSchema);

module.exports = User;
