# Perl script for application of concordance lists to process bibliographic metadata
###Background and Introduction
<p>Sometimes you might not have more at hand than a delimiter-separated value list containing significant changes for machine-readable bibliographic metadata.</p>
<p>Specifically, this script was created to address a provider platform change, which resulted in an altered URL syntax to retrieve the respective full texts. Thereby also the IDs within the URLs changed. Based upon a concordance list of the corresponding IDs the pre-existing sets needed to be preocessed to match the new URL schema. Old and new URL schemes themselves are encoded in the script. The programme hab been written to be applied while batch processing for an ALEPH import.</p>

###Usage
<p>All parameter variables being applied are encoded in source here. These are *$inputfile* for the filepath of concordance list, *$delimiter* to specify the value delimiter used in this list, *$processfile* for the path of file the manipulations are applied to and *$linematch* as identifier of the respective MARC/MAB data field. Futhermore the specific ID syntax (which addresses URLs here) is implemented to a hash for assignment of old and new values. This means the current version is highly specific and must be adapted to the respective use case.</p>
<p>As a result the script will deliver two output files (.sed / .rej) containig the corrected datasets and those, which don't match the given identifiers, respectively.</p>

###Known issues
<p>- in the current version the script parameters are encoded in source code, i.e. the file to be processed, the concordance list, its value delimiter (and many more variables) cannot be handed over as command line parameter when the script is started from shell</p>
<p>- script performance isn't outstanding - so be patient with larger metadata sets</p>
