public class PluginResponse {
	public Entry entry;
	public boolean insert;
	public PluginResponse() {}
	public PluginResponse(Entry entry,boolean insert) {
		this.entry = entry;
		this.insert = insert;
	}
}
