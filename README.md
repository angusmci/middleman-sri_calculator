# middleman-sri_calculator
Subresource integrity calculator for Middleman

This is a [Middleman](https://middlemanapp.com/) extension to perform [subresource integrity](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity) hash computations.

    This extension is currently under development. Use at your own risk.

Subresource Integrity hashes are used to verify that a resource such as a Javascript script or a CSS stylesheet loaded by a web page has not been modified before loading. For example, a bad actor (such as a disreputable ISP) might intercept a request for a Javascript and substitute a version of their own. The `integrity` attribute on a link specifies a hash for the file linked to. If the file doesn't match that hash, then a browser that supports SRI can issue a warning or refuse to execute the suspect file.

## Installation

This extension is not yet a published Ruby gem. You can add it to your project with:

	gem "middleman-sri_calculator", :git => 'https://github.com/angusmci/middleman-sri_calculator.git', :branch => 'develop'
	
## Configuration

Within your `config.rb` file, activate the extension and pass a list of files for which a checksum should be computed. For example:

    activate :sri_calculator do |sri|
      sri.paths = ["css/styles.css", "js/ui.js", "js/other.js"]
    end

Note that the paths provided should be relative to your `build` directory, and should represent the final version of the file. For example, if you have a Sass stylesheet named `styles.scss`, you would include `styles.css` -- the final output file -- rather than `styles.scss` -- the input file. 

## Using the calculator

The calculator will be called at the end of your site's build process, and will write a file into your `data` directory. By default, the file will be named `sri.yaml`.

On a subsequent build, the values in the data file will be available in `data.sri`. There will be one key for each file that you specified in the `paths` option. The keys will be named based on the file, by replacing any non-alphanumeric characters in the file path by underscores. For example, the path `css/styles.css` will generate a key `css_styles_css`.

You can reference these data values in your templates, but you should bear in mind that if the checksum has not been computed yet, trying to access the data value will fail. So instead of doing:

    <link rel="stylesheet" 
          href="/css/styles.css" 
          integrity="<%= data.sri.css_styles_css %>" />
    
you should do something like:

    <link rel="stylesheet" 
          href="/css/styles.css" 
          <% if data.key?("sri") && data.sri.key?("css_styles_css") %>integrity="<%= data.sri.css_styles_css %>"<% end %> />

or

    <% if data.key?("sri") && data.sri.key?("css_styles_css") %>
    <link rel="stylesheet" 
          href="/css/styles.css" 
          integrity="<%= data.sri.css_styles_css %>" />
    <% else %>
    <link rel="stylesheet" href="/css/styles.css" />
    <% end %>
    
This should bulletproof your build against any problems caused by the data not being available.

## Advanced configuration

By default, the calculator uses the SHA384 algorithm, and uses `shasum` to generate the checksum.

If you want to change this, you can use the `template` and `prefix` options to specify an alternate command and algorithm to use. For example, you might activate the extension with:

    activate :sri_calculator do |sri|
      sri.paths = [ ... list of paths ... ]
      sri.template = "cat %s | openssl dgst -sha256 -binary | openssl enc -base64 -A"
      sri.prefix = "sha256"
    end

The default activation corresponds to:

    activate :sri_calculator do |sri|
      sri.paths = [ ... list of paths ... ]
      sri.template = "shasum -b -a 384 %s | xxd -r -p | base64"
      sri.prefix = "sha384"
    end
    
You can also specify a different data file in place of the default `sri.yaml`, with something like:

    activate :sri_calculator do |sri|
      sri.paths = [ ... list of paths ... ]
      sri.datafile = "mysubresourceintegritydata.yaml"
    end
    
If you do this, remember to change the way you access the data from your templates: the name of the datafile is used to determine the keys used in Middleman's global `data` variable.

## Limitations

### Out-of-date hashes

A major limitation of this extension is that it can only compute hashes after the build has been completed. This means that the hash used in the build will always refer to a previous version of the file (or be empty, if no previous version exists).

What this means is that if you make a change to a subresource, such as a stylesheet, then the hash written in your HTML files will be incorrect. You must re-run a complete build to recompute a correct hash. If your subresource changes constantly -- for example, if your build tools write a build number or date into the subresource -- then you will never get a correct hash for the file; you'll always be one version behind, defeating the purpose of the extension.

The sequence of operations is as follows:

1. Middleman reads hash values from the `data/sri.yaml` file.
2. Middleman builds the site, including subresources such as stylesheets.
3. The `SRICalculator` extension computes new hashes and writes them to `data/sri.yaml`.

Obviously, this isn't ideal. Unfortunately, there's no way around it. What we'd really like to have happen is to have all the resources built before Middleman begins its main build, _then_ run the calculator to compute hashes, and _then_ have Middleman load the hashes from `data/sri.yaml`. But that isn't how Middleman works.

Middleman does provide an `after_render` hook which is called after each file is rendered. It might be possible to check the file rendered to see if it's one of the resources we're tracking, then compute a hash, and use that value to update the stored hash in `data` dynamically. Unfortunately, there are problems with this approach as well: for one thing, when `after_render` is called, the file has still not been written to disk. For another, while stylesheets seem typically to be the first items written out by Middleman, Javascripts can be written at any point in the build process. There is a danger that you could get an inconsistent site, where half the HTML files uses one hash, and half use another.

A possible partial fix might be to manually delete the `data/sri.yaml` file before building whenever one of your tracked resources has changed. This will result in a build of your site with _no_ integrity attributes, but at least the site won't be built with the _wrong_ integrity attributes.

### No Windows support

The extension has not been tested on Windows. If you do wish to use it on Windows, you will need at the very least to provide an alternate command template to compute the hash, as the `shasum` and `xxd` programs may not be available on Windows.


