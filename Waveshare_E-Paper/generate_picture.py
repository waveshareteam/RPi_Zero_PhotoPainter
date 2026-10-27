import argparse
import json
import os
import random
import shutil
import subprocess
import sys
import time

def validate_args(args):
    """Validate the validity of command-line arguments"""
    # Validate output directory
    if not os.path.exists(args.output_dir):
        try:
            os.makedirs(args.output_dir, exist_ok=True)
            print(f"Created output directory: {args.output_dir}")
        except PermissionError:
            print(f"Error: No permission to create directory {args.output_dir}")
            sys.exit(1)
    elif not os.path.isdir(args.output_dir):
        print(f"Error: {args.output_dir} is not a directory")
        sys.exit(1)

    # Validate prompt file
    if not args.prompt and not os.path.exists(args.prompts):
        print(f"Error: Prompt file does not exist: {args.prompts}")
        sys.exit(1)

    # Validate model path
    if not os.path.exists(args.model):
        print(f"Error: Model path does not exist: {args.model}")
        sys.exit(1)

    # Validate numerical parameters
    try:
        args.seed = int(args.seed)
        args.steps = int(args.steps)
        args.width = int(args.width)
        args.height = int(args.height)
    except ValueError as e:
        print(f"Parameter conversion error: {e}")
        sys.exit(1)

    if args.seed <= 0:
        print("Error: Seed must be a positive integer")
        sys.exit(1)
    if args.steps < 1 or args.steps > 100:
        print("Warning: Steps should ideally be between 1-100")

def choose_prompt(filename: str):
    """Randomly select prompt combinations from JSON file"""
    try:
        with open(filename, encoding='utf-8') as file:
            prompts = json.load(file)
        if not isinstance(prompts, list) or not all(isinstance(part, list) for part in prompts):
            raise ValueError("Invalid prompt file format")
        return ' '.join(random.choice(part) for part in prompts)
    except Exception as e:
        print(f"Failed to load prompt file: {e}")
        sys.exit(1)

def run_sd_command(cmd, fullpath):
    """Run Stable Diffusion command and display progress"""
    print(f"Starting image generation...")
    start_time = time.time()
    
    try:
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
            bufsize=1
        )
        
        # Simple progress display
        last_update = 0
        while True:
            output = process.stdout.readline()
            if output == '' and process.poll() is not None:
                break
            if output:
                # Can parse progress based on actual SD output format
                print(output.strip())
                # Example progress display logic
                current_time = time.time()
                if current_time - last_update > 5:
                    print(f"Running time: {int(current_time - start_time)} seconds")
                    last_update = current_time
        
        elapsed = time.time() - start_time
        if process.returncode != 0:
            print(f"Generation failed, return code: {process.returncode}")
            sys.exit(process.returncode)
        
        print(f"Image generation completed, time elapsed: {elapsed:.2f} seconds")
        if os.path.exists(fullpath):
            print(f"Image size: {os.path.getsize(fullpath) / 1024:.2f} KB")
        else:
            print("Warning: Generated image file not found")
            
    except Exception as e:
        print(f"Error occurred while executing command: {e}")
        sys.exit(1)

def main():
    # Get directory of current script (Waveshare_E-Paper)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Default output directory: parent directory/output_dir (PaperPiAI/output_dir)
    default_output_dir = os.path.join(script_dir, "..", "output_dir")
    
    # Default prompts file: script directory/flowers.json (Waveshare_E-Paper/flowers.json)
    default_prompts = os.path.join(script_dir, "flowers.json")
    
    parser = argparse.ArgumentParser(description="Generate random images using Stable Diffusion")
    
    # Set output_dir as optional parameter with default path
    parser.add_argument(
        "output_dir", 
        nargs='?',
        default=default_output_dir,
        help=f"Directory to save output images (default: {default_output_dir})"
    )
    
    parser.add_argument("--prompt", default="", help="Direct prompt to use, overriding prompt file")
    
    # Prompt-related parameters
    parser.add_argument("--prompts", default=default_prompts, help="Path to prompt configuration file")

    # Generation control parameters
    parser.add_argument("--seed", type=int, default=random.randint(1, 10000), help="Random seed for reproducibility")
    parser.add_argument("--steps", type=int, default=5, help="Number of generation steps (higher = better quality but slower)")
    parser.add_argument("--width", type=int, default=800, help="Image width")
    parser.add_argument("--height", type=int, default=480, help="Image height")
    
    # Model-related parameters
    parser.add_argument("--sd", default="OnnxStream/src/build/sd", help="Path to Stable Diffusion binary")
    parser.add_argument("--model", default="models/stable-diffusion-xl-turbo-1.0-anyshape-onnxstream", help="Path to Stable Diffusion model")

    # Additional parameters
    parser.add_argument("--overwrite", action="store_true", help="Overwrite existing output files")
    parser.add_argument("--no-copy", action="store_true", help="Do not copy to shared file")

    args = parser.parse_args()
    
    # Validate parameters and create directories before any operations
    validate_args(args)
    
    output_dir = args.output_dir
    shared_file = 'output.png'

    # Select prompt
    prompt = args.prompt
    if not prompt:
        prompt = choose_prompt(args.prompts)
    
    # Generate unique filename
    safe_prompt = "".join(c if c.isalnum() else "_" for c in prompt[:50])
    unique_arg = f"{safe_prompt}_seed_{args.seed}_steps_{args.steps}"
    fullpath = os.path.join(output_dir, f"{unique_arg}.png")
    
    # Check if file exists
    if os.path.exists(fullpath) and not args.overwrite:
        print(f"File already exists: {fullpath}")
        print("Use --overwrite to replace existing file")
        sys.exit(0)

    # Construct command
    cmd = [
        args.sd,
        "--xl", "--turbo",
        "--models-path", args.model,
        "--rpi-lowmem",
        "--prompt", prompt,
        "--seed", str(args.seed),
        "--output", fullpath,
        "--steps", str(args.steps),
        "--res", f"{args.width}x{args.height}"
    ]

    # Display execution information
    print(f"Generating image with prompt: '{prompt}'")
    print(f"Using seed: {args.seed}")
    print(f"Saving to: {fullpath}")
    
    # Execute command (directory is guaranteed to exist at this point)
    run_sd_command(cmd, fullpath)
    
    # Copy to shared file
    if not args.no_copy:
        shared_fullpath = os.path.join(output_dir, shared_file)
        try:
            shutil.copyfile(fullpath, shared_fullpath)
            print(f"Copied to shared file: {shared_fullpath}")
        except Exception as e:
            print(f"Failed to copy file: {e}")

if __name__ == "__main__":
    main()