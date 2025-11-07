import subprocess
import glob
import logging
import sys

# Configuration du logger
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class WebsphereManager:
    """Class to manage WebSphere and IHS servers."""
    
    def __init__(self):
        """Initialize the WebsphereManager with default values."""
        self.product = None
        self.dict_ihs = {}
        self.dict_jvm = {}
        
        # Mapping product types to their installation directories
        self.product_mapping = {
            "Liberty": [
                "/apps/WebSphere", 
                "/opt/IBM/WebSphere/Liberty", 
                "/usr/IBM/WebSphere/Liberty", 
                "/opt/wlp",
                "/apps/WebSphere/Liberty",
                "/apps/wlp",
                "/opt/IBM/wlp",
                "/usr/wlp"
            ],
            "Was_8": ["/apps/WebSphere85", "/apps/WebSphere855", "/opt/IBM/WebSphere/AppServer8"],
            "Was_9": ["/apps/WebSphere95", "/apps/WebSphere9", "/opt/IBM/WebSphere/AppServer"]
        }
    
    def check_product(self) -> list:
        """
        Check for WebSphere installations in the /apps and /opt directories.
        
        Returns:
            List[str]: List of found WebSphere directories
        """
        try:
            result = subprocess.run(
                ['find', '/apps', '/opt', '/usr', '-type', 'd', '-name', 'WebSphere*', '-o', '-name', 'wlp'],
                universal_newlines=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=30  # Add timeout to prevent hanging
            )
            
            if result.returncode != 0:
                logger.error(f"Error executing find command: {result.stderr}")
                return []
            
            # Split the output by lines and filter out any empty lines
            dirs = [d for d in result.stdout.split('\n') if d]
            logger.debug(f"Found WebSphere directories: {dirs}")
            return dirs
            
        except subprocess.TimeoutExpired:
            logger.error("Find command timed out")
            return []
        except subprocess.SubprocessError as e:
            logger.error(f"Subprocess error: {str(e)}")
            return []
        except Exception as e:
            logger.error(f"Unexpected error checking product: {str(e)}")
            return []
    
    def set_product(self) -> str:
        """
        Determine which WebSphere product is installed.
        
        Returns:
            str: The detected product type ('Liberty', 'Was_8', 'Was_9', or '')
        """
        try:
            dirs = self.check_product()
            product = ""
            
            for key, value in self.product_mapping.items():
                for path in value:
                    if any(d.startswith(path) for d in dirs):
                        product = key
                        break
                if product:
                    break
            
            if not product:
                logger.warning("Could not determine WebSphere product type")
            else:
                logger.info(f"Detected WebSphere product: {product}")
            
            self.product = product
            return product
            
        except Exception as e:
            logger.error(f"Error setting product: {str(e)}")
            return ""
    
    def list_matching_paths(self, pattern: str) -> list:
        """
        Find paths matching the given pattern.
        
        Args:
            pattern (str): Glob pattern to match
        
        Returns:
            List[str]: List of matching paths
        """
        try:
            matching_paths = glob.glob(pattern)
            logger.debug(f"Found {len(matching_paths)} paths matching pattern '{pattern}'")
            return matching_paths
        except Exception as e:
            logger.error(f"Error finding matching paths: {str(e)}")
            return []

if __name__ == "__main__":
    manager = WebsphereManager()
    product = manager.set_product()
    print(product if product else "None")
    sys.exit(0)
