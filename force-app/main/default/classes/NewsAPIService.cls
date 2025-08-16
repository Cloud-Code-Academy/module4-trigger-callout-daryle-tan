/**
 * Service class to interact with the NewsAPI for fetching top headlines
 */
public with sharing class NewsAPIService {
    // TODO: Define API endpoint constants
    private static final String API_NAMED_CREDENTIAL = 'callout:NewsAPI'; //https://newsapi.org
    private static final String API_ENDPOINT = '/v2/top-headlines';
    private static final String API_ENDPOINT_COUNTRY = '?country=';
    private static final String API_PARAM_CATETEGORY = '?category=';
    private static final String API_PARAM_PAGE_SIZE = '&pageSize=';
    private static final String API_PARAM_PAGE = '&page=';
    // TODO: Define default parameters
    private static final Integer PAGE_SIZE = 20; 
    private static final String US_COUNTRY = 'us';
    /**
     * Fetches top headlines for a specified category with pagination support
     * @param category The news category (business, entertainment, general, health, science, sports, technology)
     * @param page Page number for pagination
     * @return NewsAPIResponse The wrapper object containing the API response
     */
  
    public static NewsAPIResponse getTopHeadlinesByCategory(String category, Integer page) {
        // TODO: Implement method to fetch headlines by category
        String endpoint = API_ENDPOINT 
                + API_ENDPOINT_COUNTRY 
                + US_COUNTRY 
                + API_PARAM_CATETEGORY 
                + category;

        HttpResponse response = makeCallout(endpoint);
        // TODO: Implement method to handle response)
        // - Validate parameters
        // - Build the request URL with fixed page size
        // - Make the callout
        // - Parse and return the response
        if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
            return parseResponse(response.getBody());
        } else {
            throw new NewsAPIException('Callout failed : ' + response.getBody());
        }
    }
    
    /**
     * Helper method to make the HTTP callout
     * @param endpoint The full URL with parameters
     * @return HttpResponse The HTTP response
     */
    private static HttpResponse makeCallout(String endpoint) {
        // TODO: Implement HTTP callout
        // - Create and configure HTTP request
        // - Make the callout
        // - Handle exceptions
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(API_NAMED_CREDENTIAL + endpoint);
        request.setMethod('GET');
        try {
            return http.send(request);
        } catch(Exception e) {
            throw new NewsAPIException('Callout error: ' + e.getMessage());
        }  
    }
    
    /**
     * Helper method to parse the JSON response
     * @param jsonResponse The JSON response string
     * @return NewsAPIResponse The parsed response object
     */
    private static NewsAPIResponse parseResponse(String jsonResponse) {
        // TODO: Implement JSON parsing
        // - Deserialize JSON to NewsAPIResponse
        // - Handle exceptions
        try {
            return (NewsAPIResponse) JSON.deserialize(jsonResponse, NewsAPIResponse.class);
        } catch (Exception e) {
            throw new NewsAPIException('Error parsing response: ' + e.getMessage());
        }
    }
    
    /**
     * Custom exception class for NewsAPI errors
     */
    public class NewsAPIException extends Exception {}
} 