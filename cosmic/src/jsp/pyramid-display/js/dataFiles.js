const dataFiles = [
		'Run181_list_swap_00_01.txt',
		'Run132_list_no_swap.txt',
		'Run132_list_no_swap_converted.txt',
		'Run133_list_no_swap.txt',
		'Run167_list_no_swap.txt',
		'Run168_list_swap_00_01.txt',
		'Run171_list_no_swap.txt',
		'Run172_list_no_swap.txt',
		'Run173_list_swap_00_01.txt',
		'Run174_list_swap_00_01.txt',
		'Run116_list_no_swap.txt',
		'Run142_list_swap_00_01.txt',
		'Run151_list_no_swap.txt',
		'Run156_list_no_swap.txt',
		'Run158_list_swap_00_01.txt',
		'Run161_list_swap_00_01.txt',
		'Run167Sample.txt',
		'Run132_list_cluster_no_swap.txt',
		'Run133_list_cluster_no_swap.txt',
		'Run167_list_cluster_no_swap.txt',
		'Run168_list_cluster_swap_00_01.txt',
		'Run171_list_cluster_no_swap.txt',
		'Run172_list_cluster_no_swap.txt',
		'Run173_list_cluster_swap_00_01.txt',
		'Run174_list_cluster_swap_00_01.txt',
		'Run181_list_cluster_swap_00_01.txt',
]
// Export functions for ES module consumers and also attach to globalThis for legacy code.
export {
  dataFiles,
 };
// Also expose to global scope for backward compatibility
if (typeof window !== 'undefined') {
  window.dataFiles = dataFiles;
}

// CommonJS fallback for tests or environments using require()
if (typeof module !== 'undefined' && typeof module.exports !== 'undefined') {
  module.exports = {
    dataFiles,
  };
 }