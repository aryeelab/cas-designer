workflow cas_designer {
  
  String version = "dev"
  
  # dev pipeline versions have the 'latest' image tag.
	# release pipeline versions correspond to images tagged with the version number
	#String image_id = sub(version, "dev", "latest")
  String image_id = if version=="dev" then "latest" else version
  
  call off_target_search {input:  image_id = image_id}
  call version_info {input: version = version, image_id = image_id}
}


task off_target_search {
  String target_id
  String target_name
  String genome
  String target_sequence
  Int target_length
  String pam
  String pam_target
  Int num_mismatches
  Int dna_bulge_size
  Int rna_bulge_size
  String image_id
  
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
    mv input.txt ${target_id}.txt

    # Call cas-designer
    cas-designer ${target_id}.txt
    
    # List output files
    ls      
  >>>
  
  runtime {
      docker: "gcr.io/joung-pipelines/cas-designer"
      cpu: 8
      memory: "30G"
      gpuType: "nvidia-tesla-v100"
      gpuCount: 1
      preemptible: 1
  }
  
  output {
     File target_fasta = "${target_name}.fa"
     File input_file = "${target_id}.txt"
     File offtargets = "${target_id}-offtargets.txt"
     File mich_patterns = "${target_id}-mich_patterns.txt" 
     File dna_bulges = "${target_id}-dna_bulges.txt"
     File rna_bulges = "${target_id}-rna_bulges.txt"
     File summary = "${target_id}-summary.txt"
     File gpu_info = "nvidia-smi.txt"
  }
}

task version_info {
	String version
	String image_id
	command <<<
		cat /VERSION
	>>>
	runtime {
            docker: "gcr.io/joung-pipelines/cas-designer"
            cpu: 1
  }
	output {
	    String pipeline_version = read_string(stdout())
  }
}
