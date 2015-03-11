---
layout: post
title: "Deploying an Ember CLI application through SSH"
date: 2015-03-09 15:02:55 -0700
comments: true
categories: 
---

Want to serve up your [Ember CLI][] application via Nginx/Apache or another web server software?  Let's learn how!

## Ember-CLI-Deploy

[Ember-CLI-Deploy][] is "an Ember CLI addon for lightning fast deployments of Ember CLI apps".  Using Ember-CLI-Deploy is preferable using to another static asset deployment solution because **it caters to the needs of an Ember CLI app**.

Last week at EmberConf 2015, Luke Melia [announced during his talk][luke's talk] that the three big competing Ember-CLI deployment solutions (ember-deploy, front-end-builds, and ember-cli-deploy) will be merging into a single ember-cli-deploy package based largely on ember-deploy.

Note that whenever you see "ember-deploy" post you can treat this as synonymous with "ember-cli-deploy".

## Why SSH instead of S3?

You can host your entire front-end website to Amazon S3 with [ember-deploy-s3-index][] and [ember-deploy-s3][].

If you use Ember CLI's default location behavior, your routes will use non-hash URLs on modern browsers (e.g. [/resources][] instead of [/#/resources][]).  This means that you need S3 to properly serve up all of your routes (not just the `/` path).  As an AWS beginner, the easiest solution I found was to set the 404 page to `index.html`.  This returns a 404 for all routes, which is obviously not ideal.

After failing to find a simple and elegant solution using an S3 bucket for my Ember CLI app's `index.html` file, I decided to move it onto my server and serve it through Nginx.

## Ember-Deploy-SSH-Index

I went looking for an ember-cli-deploy adapter that would allow my to upload my files to a directory on my web server.  I didn't find any such adapters.  Inspired by Kerry Gallagher's blog posts about [the making of ember-deploy-s3-index][] and [making ember-deploy adapters][], I decided to try to make an adapter that suited my needs: [ember-deploy-ssh-index][].

After looking for Node.js-based SSH/SCP/Rsync libraries, I decided to use the pure JS [ssh2][] library to manage the SSH connections.  I looked at the in-progress [ember-cli-deploy][] documentation, and the [ember-deploy-s3-index][] code to determine how my adapter should work.

Following the [ember-cli-deploy][] API, my library includes:

- an `upload` function that uploads the current index page to a file named based on the [ember-cli-deploy][] tag (the git hash)
- a `list` function that lists the files in the remote directory on the server
- an `activate` function that links the `index.html` file to a given revision file

## Usage

You can use [ember-deploy-ssh-index][] and [ember-deploy-s3][] to host your static assets on S3 and your index page through your own web server.

First, install [ember-cli-deploy][] and our adapters into your [Ember CLI][] app:

```bash
$ npm install --save-dev ember-cli-deploy ember-deploy-ssh-index ember-deploy-s3
```

Now make a `config/deploy.js` file with your SSH and S3 configuration.  I prefer to store my AWS credentials and SSH private key filename in environment variables, but a gitignore'd configuration file or Node.js module would work as well.

```js
/* jshint node: true */

module.exports = {
  production: {
    store: {
      type: "ssh",
      remoteDir: "/var/www/",
      host: "example.com",
      username: "root",
      privateKeyFile: process.env.SSH_KEY_FILE,
    },
    assets: {
      type: "s3",
      accessKeyId: process.env.AWS_KEY,
      secretAccessKey: process.env.AWS_SECRET,
      bucket: "assets.example.com",
    },
  },
  development: {
    // Add a development configuration here, similar to the production one above
  },
};
```

Because we're storing our static assets at a base different URL from our index page, we'll need to prepend a base URL to our asset paths.  Let's update our `EmberApp` definition in our `Brocfile.js` to reflect that change:

```js
var app = new EmberApp({
  fingerprint: {
    prepend: 'https://s3.amazonaws.com/assets.example.com/',
  },
});
```

Now we should be able to upload our application:

```bash
$ ember deploy -e production
```

And activate our current revision:

```bash
$ export tag="example:$(git rev-parse --short HEAD)"  # change "example" to your app name
$ ember deploy:activate deploy:activate --revision $tag --environment production
```

Take a look at the [README file][] for more documentation on the usage of [ember-deploy-ssh-index][].


## Next Steps

[ember-deploy-ssh-index][] is the first [Ember CLI][]-related NPM module I have made.  I have only used it to deploy a single website, [Free Music Ninja][].  I have also not yet written any tests for it so it's probably broken.

My future plans include:

1. [Write tests.][#3]  <q>Code without tests is broken by design</q> - <cite>Jacob Kaplan Moss</cite>
2. [Possibly rename app][#10]: `ember-deploy-ssh-index` to `ember-cli-deploy-ssh-index`
3. [Support SSH config file][#7] (`~/.ssh/config`)

At this point I am the only person who has worked with this adapter and I would love some feedback!  Have an opinion or want to help out fix/improve this adapter?  **Please open an issue, comment below, tweet me, or email me.**

[ember cli]: http://ember-cli.com
[ember-deploy-s3]: https://github.com/LevelbossMike/ember-deploy-s3 
[ember-deploy-s3-index]: https://github.com/Kerry350/ember-deploy-s3-index 
[ember-cli-deploy]: https://github.com/ember-cli/ember-cli-deploy
[/resources]: https://freemusic.ninja/resources
[/#/resources]: https://freemusic.ninja/#/resources
[the making of ember-deploy-s3-index]: http://kerrygallagher.co.uk/the-making-of-ember-deploy-s3-index/
[making ember-deploy adapters]: http://kerrygallagher.co.uk/making-ember-deploy-adapters/
[luke's talk]: https://www.youtube.com/watch?v=4EDetv_Rw5U
[ssh2]: https://github.com/mscdex/ssh2
[readme file]: https://github.com/treyhunner/ember-deploy-ssh-index#readme
[ember-deploy-ssh-index]: https://github.com/treyhunner/ember-deploy-ssh-index
[free music ninja]: https://freemusic.ninja/
[#3]: https://github.com/treyhunner/ember-deploy-ssh-index/issues/3
[#10]: https://github.com/treyhunner/ember-deploy-ssh-index/issues/10
[#7]: https://github.com/treyhunner/ember-deploy-ssh-index/issues/7
