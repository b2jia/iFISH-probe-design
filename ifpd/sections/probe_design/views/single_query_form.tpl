
<form id="single_probe_form" action="{{app_uri}}single_query" method="post">

	<div class="card bg-primary text-white mb-3">
		<div class="card-body">
			<h3 class="card-title">General</h3>
			<div class="row">
				<div class="form-group col col-3">
					<label for="name">Name</label>
					<input type="text" name="name" id="name" class="form-control" placeholder="Query name" data-toggle="tooltip" data-placement="bottom" title="Used to search for the query." />
				</div>

				<div class="form-group col col-9">
					<label for="description">Description</label>
					<textarea name="description" id="description" rows="3" class="form-control" placeholder="Query description"></textarea>
				</div>
			</div>
		</div>
	</div>

	<div class="card border-info mb-3">
		<div class="card-body">
			<h3 class="card-title">Where</h3>
			<div class="row">
				<div class="form-group col col-3">
					<label for="database">Database</label>
					% if 0 != len(dblist):
					<select name="database" id="database" class="form-control">
					% for (dbName, dbDir) in dblist.items():
						<option value="{{dbDir}}">{{dbName}}</option>
					% end
					</select>
					% else:
					<input type="text" class="form-control" placeholder="No databases found." readonly/>
					% end
					<script type="text/javascript">
						get_db_chrList = function(dbDir, target) {
							$.get('{{app_uri}}listChr/'+dbDir, {}, function(data) {
								$(target).children().remove();
								for (var i = data['chrList'].length - 1; i >= 0; i--) {
									chrLabel = data['chrList'][i];
									chrOption = $('<option value="' + chrLabel + '">' + chrLabel + '</option>');
									$(target).append(chrOption);
								}
							}, 'json');
						}
						$('#database').change(function(e) {
							get_db_chrList($(this)[0].value, '#chromosome');
						})
						get_db_chrList($('#database')[0].value, '#chromosome');
					</script>
				</div>

				<div class="form-group col col-3">
					<label for="chromosome">Chromosome</label>
					<select name="chromosome" id="chromosome" class="form-control">
					</select>
				</div>

				<div class="form-group col col-3">
					<label for="start">Start position</label>
					<input type="number" name="start" id="start" class="form-control" placeholder="0" value=0 min=0 />
				</div>

				<div class="form-group col col-3">
					<label for="end">End position</label>
					<input type="number" name="end" id="end" class="form-control" placeholder="0" value=0 min=0 />
				</div>
			</div>
		</div>
	</div>

	<div class="card border-info mb-3">
		<div class="card-body">
			<h3 class="card-title">What</h3>

			<div class="row">
				<div class="form-group col col-4">
					<label for="n_oligo"># Oligomers</label>
					<input type="number" name="n_oligo" id="n_oligo" class="form-control" placeholder=48 value=48 min="1" />
				</div>

				<div class="form-group col col-4" data-toggle="tooltip" data-placement="bottom" title="%range around best value.">
					<label for="f1_threshold">Feature #1 threshold<sup>2</sup></label>
					<input type="number" name="f1_threshold" id="f1_threshold" class="form-control" placeholder=0.1 value=0.1 min="0" max="1" step="0.0000001" />
				</div>

				<div class="form-group col col-4" data-toggle="tooltip" data-placement="bottom" title="Set to -1 to retrieve all probes.">
					<label for="max_probes">Max output probes<sup>1</sup></label>
					<input type="number" name="max_probes" id="max_probes" class="form-control" placeholder=5 value=5 min=-1 />
				</div>
			</div>
		</div>
	</div>

	<div id="probe-advanced" class="card border-danger mb-3">
		<div class="card-body">
			<h3 class="card-title">Advanced settings</h3>
			<table class="table table-bordered tac">
				<thead>
					<th class='tac'>Feature</th>
					<th class='tac'>
						Size<br />
						<small>(minimize)</small>
					</th>
					<th class='tac'>
						Centrality<br />
						<small>(maximize)</small>
					</th>
					<th class='tac'>
						Spread<br />
						<small>(homogeneous)</small>
					</th>
				</thead>
				<tr>
					<td>
						#1, select<sup>2</sup>
					</td>
					<td><input class='radio-feature' type="radio" name='f1' value='size' checked /></td>
					<td><input class='radio-feature' type="radio" name='f1' value='centrality' /></td>
					<td><input class='radio-feature' type="radio" name='f1' value='spread' /></td>
				</tr>
				<tr>
					<td>
						#2, rank
					</td>
					<td><input class='radio-feature' type="radio" name='f2' value='size' /></td>
					<td><input class='radio-feature' type="radio" name='f2' value='centrality' /></td>
					<td><input class='radio-feature' type="radio" name='f2' value='spread' checked /></td>
				</tr>
				<tr>
					<td>
						#3
					</td>
					<td><input class='radio-feature' type="radio" name='f3' value='size' /></td>
					<td><input class='radio-feature' type="radio" name='f3' value='centrality' checked /></td>
					<td><input class='radio-feature' type="radio" name='f3' value='spread' /></td>
				</tr>
			</table>
		</div>
	</div>

	<div class="wrap_submit">
		<input type="submit" class="btn btn-success" />
	</div>

	<div class="col-xs-12">
		<p><small><sup>1</sup> The more probe candidates you want in your output, the longer generating plots will take.</small></p>
		<p><small><sup>2</sup> Candidates will be selected based on feature #1, in a range <code>&plusmn;(best_f1_value · threshold)</code>.</small></p>
	</div>

</form>

<script type="text/javascript">

// Feature selection behaviour
$('#single_probe_form .radio-feature').change(function(e) {

	// Identify changed column
	var curname = $(this).attr('name');
	var curval = $(this).val();

	// Empty rest of the row
	$('#single_probe_form .radio-feature:not([name="' + curname + '"])').each(function(k, v) {
		if ( curval == $(v).val() ) {
			$(v).prop('checked', false);
		}
	});

	// Find empty column
	var ecol = ''
	$.each(['f1', 'f2', 'f3'], function(k, v) {
		if ( undefined == $('#single_probe_form .radio-feature[name=' + v + ']:checked').val()) {
			ecol = v;
			return false;
		}
	});

	// Find empty row
	var erow = ''
	$.each(['size', 'centrality', 'spread'], function(k1, v1) {
		found = false;

		$.each(['f1', 'f2', 'f3'], function(k2, v2) {
			if ( v1 == $('#single_probe_form .radio-feature[name=' + v2 + ']:checked').val()) {
				found = true;
				return false;
			}
		});

		if ( !found ) {
			erow = v1;
			return(false);
		}
	});

	// Fill empty space
	$('#single_probe_form .radio-feature[name=' + ecol + '][value=' + erow + ']').prop('checked', true);

});

// Minimum value
$('input[name="n_oligo"]').change(
	function(e) {
		if ( $(this).val() < 1 ) {
			$(this).val(1);
		}
	}
);
$('input[name="start"]').change(
	function(e) {
		if ( $(this).val() < 1 ) {
			$(this).val(0);
		}
	}
);
$('input[name="end"]').change(
	function(e) {
		if ( $(this).val() < 1 ) {
			$(this).val(0);
		}
	}
);
$('input[name="max_probes"]').change(
	function(e) {
		if ( $(this).val() < -1 || $(this).val() == 0 ) {
			$(this).val(-1);
		}
	}
);

</script>

<script type="text/javascript">
$(function () {

	// Enable tooltips
	$('[data-toggle="tooltip"]').tooltip()

})
</script>

