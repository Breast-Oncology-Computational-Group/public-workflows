# Method for Extracting Loss of Heterozygosity Events from Gene-Annotated Copy Number Segment Files

This workflow extracts and categorizes loss of heterozygosity (LOH) events from gene-annotated copy number segment files. The analysis is performed using the `extract_loh` workflow defined in `extract_loh.wdl`.

## Loss of Heterozygosity Types

The workflow identifies and classifies LOH events into the following categories:

1. **CL-LOH (Copy Loss LOH)**: Loss of heterozygosity accompanied by a decrease in copy number (typically to copy number 1).

2. **CN-LOH (Copy Neutral LOH)**: Loss of heterozygosity where the total copy number remains at 2, but both copies come from the same parent (uniparental disomy).

3. **LOH (Other)**: Other forms of loss of heterozygosity that don't fall into the above categories, such as total copy number larger than 2 and come from the same parent.

## Usage

The workflow takes a gene-annotated copy number segment file as input and produces a tab-separated output file containing identified LOH events with their classifications.

See `loh_extraction.inputs.json` for the required input format.