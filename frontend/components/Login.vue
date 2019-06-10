<template>
  <div class="content">
    <form class="pure-form">
      <h1>Log In</h1>
      <fieldset class="pure-group">
        <input type="text" name="username" placeholder="Username" />
      </fieldset>
      <fieldset class="pure-group">
        <input type="password" name="password" placeholder="Password" />
      </fieldset>

      <fieldset class="pure-group">
        <label for="remember" class="pure-checkbox">
          <input id="remember" type="checkbox"> Secure Login
        </label>
      </fieldset>
      <input type="submit" class="pure-button pure-button-primary" value="Login" />
    </form>
  </div>
</template>
<script>
  export default {
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
