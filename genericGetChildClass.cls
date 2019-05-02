public class genericGetChildClass {
    
    public static Map<String,List<Sobject>> getAllChildRecord(id RecordID)
    {
        Map<String,List<Sobject>> resultValue = new Map<String,List<Sobject>>();
        Map<string,String> getChildRelationshipName = new Map<string,String>();
        Map<string,string> mapString =getRelatedObjects(String.valueOf(RecordID.getsobjecttype()),getChildRelationshipName);
        String Query='Select ';
        SObjectType parentType = Schema.getGlobalDescribe().get(String.valueOf(RecordID.getsobjecttype()));
        Map<String,Schema.SObjectField> parentfields = parentType.getDescribe().fields.getMap();
        Integer i=0;
        for(String field:parentfields.keyset())
        {
            if(i==0)
            {
                Query=Query+field;
            }
            else
            {
                Query=Query+','+field; 
            }
            i=i+1;
        }
        
        for(String key:mapString.keyset())
        {
            Query=Query+',(select ';
            SObjectType objectType = Schema.getGlobalDescribe().get(key);
            Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
            Integer j=0;
            for(String field:mfields.keyset())
            {
                if(j==0)
                {
                    Query=Query+field;
                }else
                {
                    Query=Query+','+field; 
                }
                j++;
            }
            Query=Query+' from '+getChildRelationshipName.get(key)+')';
        }
        Query=Query+' from '+String.valueOf(RecordID.getsobjecttype())+' where id=\''+RecordID+'\'';
        List<Sobject> sourceObjects = (List<SObject>)Type.forName('List<' + String.valueOf(RecordID.getsobjecttype()) + '>').newInstance();
        sourceObjects = Database.query(Query);
        for(sobject s:sourceObjects)
        {
            for(String childName:getChildRelationshipName.keyset())
            {
                String childreationShipName = getChildRelationshipName.get(childName);
                if(s.getSObjects(childreationShipName)!=null){
                    for(sobject child:s.getSObjects(childreationShipName))
                    {
                       if(resultValue.containsKey(childName))
                       {
                          resultValue.get(childName).add(child);
                       }
                        else
                        {
                            List<Sobject> recordList = new List<Sobject>();
                            recordList.add(child);
                            resultValue.put(childName,recordList);
                        }
                    }
                }
            }
        }
        return resultValue;
    }
    
    public static map<string,string> getRelatedObjects(string masterObjectName,Map<String,String> childRelationshipName){
        map<string,string> relatedObjectsMap = new map<string,string>();
        list<Schema.Childrelationship> relatedObjectsList = Schema.getGlobalDescribe().get(masterObjectName).getdescribe().getChildRelationships();
        for (Schema.Childrelationship  relatedObject : relatedObjectsList) {
            if(relatedObject.getChildSObject().getDescribe().isUpdateable()
               && 
               relatedObject.getChildSObject().getDescribe().getKeyPrefix()!=null
               && 
               !relatedObject.getChildSObject().getDescribe().isCustomSetting()
               &&
               relatedObject.getChildSObject().getDescribe().isCreateable()
              )
                if(relatedObject.getRelationshipName()!=null && relatedObject.getChildSObject().getDescribe().getName().equalsIgnoreCase('Attachment')==false ){
                    childRelationshipName.put(relatedObject.getChildSObject().getDescribe().getName(),relatedObject.getRelationshipName());
                    relatedObjectsMap.put(relatedObject.getChildSObject().getDescribe().getName(),relatedObject.getChildSObject().getDescribe().getLabel());
                }
        }
        return relatedObjectsMap;
    }
    
}
