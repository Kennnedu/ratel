<template>
  <section id="content">
    <main>
      <form class="pure-form"
            v-on:submit="submitForm"
            v-bind:class="{'has-error-animation': hasError}">
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
    </main>
  </section>
</template>
<script>
  import axios from 'axios'
  import Cookies from 'js-cookie'

  export default {
    data: function(){
      return {
        username: "",
        password: "",
        secureLogin: true,
        hasError: false,
      }
    },
    methods: {
      cookies() {
        return Cookies
      },

      submitForm(e){
        e.preventDefault();
        this.hasError = false

        let _this = this;
        axios.post("/session", {
          username: _this.username,
          password: _this.password,
          secure_login: _this.secureLogin
        }).then(function(resp){
          _this.cookies().set('session_token', resp.data.session_token)
          _this.$emit('login');
        }).catch(function(error){
          _this.hasError = true;
          console.log(error.response)
        })
      }
    }
  }
</script>
<style lang="css" scoped>
  #content main{
    height: 85vh;
    display: flex;
    align-items: center;
  }

  form {
    margin: auto;
    padding: 45px;
    border: 1px solid lightgray;
    background-color: #eaeded;
    border-radius: 7px;
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

  .has-error-animation {
    animation: shake 0.82s cubic-bezier(.36,.07,.19,.97) both;
    transform: translate3d(0, 0, 0);
    backface-visibility: hidden;
    perspective: 1000px;
  }

  @keyframes shake {
  10%, 90% {
    transform: translate3d(-1px, 0, 0);
  }

  20%, 80% {
    transform: translate3d(2px, 0, 0);
  }

  30%, 50%, 70% {
    transform: translate3d(-4px, 0, 0);
  }

  40%, 60% {
    transform: translate3d(4px, 0, 0);
  }
}
</style>
