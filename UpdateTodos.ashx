<%@ WebHandler Language="C#" Class="UpdateTodos" %>

using System;
using System.Web;
using Newtonsoft.Json;
using System.Collections.Generic;

public class UpdateTodos : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
        context.Response.AppendHeader("Access-Control-Allow-Origin", "*");
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Response.Expires = -1;
        context.Response.Cache.SetAllowResponseInBrowserHistory(true);

        List<string> requestErrors = new List<string> {};
        string jsonData = "";
        
        using (var reader = new System.IO.StreamReader(context.Request.InputStream)) {
            jsonData = reader.ReadToEnd();
        }

        System.Data.DataTable dtItems = new System.Data.DataTable();
        dtItems.Columns.Add("ID", Type.GetType("System.Int32"));
        dtItems.Columns.Add("Name", Type.GetType("System.String"));
        dtItems.Columns.Add("Completed", Type.GetType("System.Boolean"));

        Newtonsoft.Json.Linq.JArray aJson = Newtonsoft.Json.Linq.JArray.Parse(jsonData);

        foreach (Newtonsoft.Json.Linq.JObject item in aJson) {
            int index = System.Convert.ToInt32(item["index"].ToString());
            string name = item["value"].ToString();
            bool done = System.Convert.ToBoolean(item["done"].ToString());

            System.Data.DataRow dRow = dtItems.NewRow();
            dRow["ID"] = index;
            dRow["Name"] = name;
            dRow["Completed"] = done;
            dtItems.Rows.Add(dRow);
        }
        dtItems.AcceptChanges();

        System.Data.DataTable dtReturnItems = saveToDoItems(dtItems);
        jsonData = JsonConvert.SerializeObject(dtReturnItems, Formatting.Indented);

        context.Response.Write(jsonData);

    }

    /// <summary>
    /// Saves your todo list.
    /// </summary>
    /// <returns>JSON Array</returns>
    private static System.Data.DataTable saveToDoItems(System.Data.DataTable dtJsonItems) {
        
        string sqlConnectionString = System.Configuration.ConfigurationManager.ConnectionStrings["BigVoltage"].ToString();

        System.Data.DataTable dtItems = new System.Data.DataTable();
        dtItems.Columns.Add("index", Type.GetType("System.Int32"));
        dtItems.Columns.Add("value", Type.GetType("System.String"));
        dtItems.Columns.Add("done", Type.GetType("System.Boolean"));
        
        using (System.Data.SqlClient.SqlConnection _sqlConn = new System.Data.SqlClient.SqlConnection(sqlConnectionString)) {
            //Open connection
            _sqlConn.Open();
            //Define command
            System.Data.SqlClient.SqlCommand _sqlCommand = new System.Data.SqlClient.SqlCommand("[dbo].[SaveToDoListItems]", _sqlConn);
            _sqlCommand.CommandType = System.Data.CommandType.StoredProcedure;
                
            System.Data.SqlClient.SqlParameter tvpParam = _sqlCommand.Parameters.AddWithValue("@TVPTodoItems", dtJsonItems);
            tvpParam.SqlDbType = System.Data.SqlDbType.Structured;
                
            System.Data.SqlClient.SqlDataReader _sqlReader = _sqlCommand.ExecuteReader();
            while (_sqlReader.Read()) {
                //Add rows to data table
                System.Data.DataRow dRow = dtItems.NewRow();
                dRow["index"] = _sqlReader.GetInt32(_sqlReader.GetOrdinal("ID"));
                dRow["value"] = _sqlReader.GetString(_sqlReader.GetOrdinal("Name"));
                dRow["done"] = _sqlReader.GetBoolean(_sqlReader.GetOrdinal("Completed"));
                dtItems.Rows.Add(dRow);
            }
            //Update table
            dtItems.AcceptChanges();
            //Close connection
            _sqlReader.Close();
            _sqlCommand.Dispose();
            _sqlConn.Close();
            _sqlConn.Dispose();
            //
            return dtItems;
        }
        
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}