workflow cas_designer {
  
  String version = "v0.8"
  
  # dev pipeline versions have the 'latest' image tag.
	# release pipeline versions correspond to images tagged with the version number
	#String image_id = sub(version, "dev", "latest")
  String image_id = if version=="dev" then "latest" else version
  
  call off_target_search {input:  image_id = image_id}
}


task off_target_search {
  String image_id
  String target_name
  String genome
  String target_sequence
  Int target_length
  String pam
  String pam_target
  Int num_mismatches
  Int dna_bulge_size
  Int rna_bulge_size
  
  String prefix = target_name + '_' + num_mismatches + '_' + dna_bulge_size + '_' + rna_bulge_size 

  command <<<
    # Output GPU info
    nvidia-smi > nvidia-smi.txt

    # Localize genome FASTA
    mkdir genome
    gsutil -m cp ${genome}/* genome/
    gunzip genome/*
    ls genome/
  
    # Create target FASTA
    echo ">${target_name}" > "${target_name}.fa"
    echo ${target_sequence} >> "${target_name}.fa"
    
    # Create cas-designer input file
    echo "genome/" > input.txt
    echo "${target_name}.fa" >> input.txt
    echo "${target_length}" >> input.txt
    echo ${pam} >> input.txt
    echo ${pam_target} >> input.txt
    echo ${num_mismatches} >> input.txt
    echo ${dna_bulge_size} >> input.txt
    echo ${rna_bulge_size} >> input.txt
    mv input.txt ${prefix}.txt

    # Call cas-designer
    cas-designer ${prefix}.txt
    
    # List output files
    ls      
  >>>
  
  runtime {
      docker: "gcr.io/joung-pipelines/cas-designer"
      memory: "4G"
      gpuType: "nvidia-tesla-v100"
      gpuCount: 1
      zones: ["us-central1-a"]
  }
  
  output {
     File target_fasta = "${target_name}.fa"
     File input_file = "${prefix}.txt"
     File offtargets = "${prefix}-offtargets.txt"
     File mich_patterns = "${prefix}-mich_patterns.txt" 
     File dna_bulges = "${prefix}-dna_bulges.txt"
     File rna_bulges = "${prefix}-rna_bulges.txt"
     File summary = "${prefix}-summary.txt"
     File gpu_info = "nvidia-smi.txt"
  }
}

