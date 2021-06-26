workflow w {
  
  String version = "dev"
  
  # dev pipeline versions have the 'latest' image tag.
	# release pipeline versions correspond to images tagged with the version number
	String image_id = sub(version, "dev", "latest")
  
  call cas_designer {input:  image_id = image_id}
}


task cas_designer {
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

  command <<<
    # Localize genome FASTA
    mkdir genome
    gsutil -m cp ${genome}/* genome/
  
    # Create target FASTA
    echo ">${target_name}" > target.fa
    echo ${target_sequence} >> target.fa
    
    # Create cas-designer input file
    echo "genome/" > input.txt
    echo "target.fa" >> input.txt
    echo "${target_length}" >> input.txt
    echo ${pam} >> input.txt
    echo ${pam_target} >> input.txt
    echo ${num_mismatches} >> input.txt
    echo ${dna_bulge_size} >> input.txt
    echo ${rna_bulge_size} >> input.txt

    # Call cas-designer
    cas-designer input.txt
    
    # List output files
    ls
      
    #echo "Started: `date`" | tee log.txt
    #nvidia-smi | tee -a log.txt
    #cas-offinder | tee -a log.txt
    #sleep 600
  >>>
  
  runtime {
      docker: "gcr.io/aryeelab/cas-designer"
      memory: "15G"
      gpuType: "nvidia-tesla-k80"
      gpuCount: 1
      zones: ["us-central1-a"]
  }
  
  output {
     File log = "log.txt"
  }
}


