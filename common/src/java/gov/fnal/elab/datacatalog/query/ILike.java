package gov.fnal.elab.datacatalog.query;

public class ILike extends QueryLeaf {
    public ILike(String key, Object value) {
        super(QueryElement.TYPES.ILIKE, key, value);
    }
}