<template>
  <div class="content">
    <form class="pure-form" v-on:submit="submitForm">
      <h1>Log In</h1>
      <fieldset class="pure-group">
        <input type="text" name="username" placeholder="Username" required v-model="username" />
      </fieldset>
      <fieldset class="pure-group">
        <input type="password" name="password" placeholder="Password" required v-model.password="password" />
      </fieldset>

      <fieldset class="pure-group">
        <label for="remember" class="pure-checkbox">
          <input id="remember" type="checkbox" v-model="secureLogin" /> Secure Login
        </label>
      </fieldset>
      <input type="submit" class="pure-button pure-button-primary" value="Login" />
    </form>
  </div>
</template>
<script>
  import axios from 'axios'

  export default {
    data: function(){
      return {
        username: "",
        password: "",
        secureLogin: false
      }
    },
    methods: {
      submitForm(e){
        e.preventDefault();

        let _this = this;
        axios.post("/session", {
          username: _this.username,
          password: _this.password,
          secure_login: _this.secureLogin
        }).then(function(resp){
          _this.$emit('login');
        }).catch(function(error){
          console.log(error.response)
        })
      }
    }
  }
</script>
<style lang="css" scoped>
  .content {
    height: calc(100vh - 50px);
    display: flex;
    align-items: center;
  }

  form {
    margin: auto;
    padding: 45px;
    border: 1px solid lightgray;
    background-color: #eaeded;
    border-radius: 3px;
  }

  form input[type='submit'] {
    width: 100%;
  }

  form h1 {
    text-align: center;
  }

  fieldset.pure-group label input {
    display: inline;
  }
</style>
