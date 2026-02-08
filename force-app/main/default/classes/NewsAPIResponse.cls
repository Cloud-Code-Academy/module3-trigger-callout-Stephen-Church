public class NewsAPIResponse {
    public String status { get; set; }
    public Integer totalResults { get; set; }
    public List<Article> articles { get; set; }
    public String code { get; set; }
    public String message { get; set; }
    public static final Integer DESCRIPTION_MAX_LENGTH = 32767;
    public static final Integer TITLE_MAX_LENGTH = 254;
    public static final Integer CONTENT_MAX_LENGTH = 131071;
    
    public class Article {
        public Source source { get; set; }
        public String author { get; set; }
        public String title { get; set; }
        public String description { get; set; }
        public String url { get; set; }
        public String urlToImage { get; set; }
        public String publishedAt { get; set; }
        public String content { get; set; }
    }
    
    public class Source {
        public String id { get; set; }
        public String name { get; set; }
    }
    
    public static Article__c convertToSObject(Article apiArticle, News_Category__c newsCategory) {
        
        Article__c article = new Article__c();
        article.News_Category__c = newsCategory.Id;
        article.Category__c = newsCategory.Name;
        article.Author__c = apiArticle.author;
        DateTime publishedDateTime = (DateTime)JSON.deserialize('"' + apiArticle.publishedAt + '"', DateTime.class);
        article.Published_At__c = publishedDateTime;
        article.Name = article.Author__c + ' - ' + article.Published_At__c;
        article.Description__c = UtilityString.getSubStringIfMaxCharsExceeded(apiArticle.description, DESCRIPTION_MAX_LENGTH);
        article.Source__c = apiArticle.source.name;
        article.Title__c = UtilityString.getSubStringIfMaxCharsExceeded(apiArticle.title, TITLE_MAX_LENGTH);
        article.url__c = apiArticle.url;
        article.Content__c = UtilityString.getSubStringIfMaxCharsExceeded(apiArticle.content, CONTENT_MAX_LENGTH);
        article.urlToImage__c = apiArticle.urlToImage;
        
        return article;
    }
} 