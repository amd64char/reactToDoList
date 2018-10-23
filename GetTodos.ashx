<%@ WebHandler Language="C#" Class="GetTodos" %>

using System;
using System.Web;
using Newtonsoft.Json;
using System.Collections.Generic;

public class GetTodos : IHttpHandler {

    public void ProcessRequest(HttpContext context) {
        context.Response.ContentType = "application/json";
        context.Response.AppendHeader("Access-Control-Allow-Origin", "*");
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Response.Expires = -1;
        context.Response.Cache.SetAllowResponseInBrowserHistory(true);

        List<string> requestErrors = new List<string> {};

        System.Data.DataTable dtItems = getToDoItems();
        string jsonItems = JsonConvert.SerializeObject(dtItems, Formatting.Indented);

        context.Response.Write(jsonItems);
    }

    /// <summary>
    /// Returns your todo list.
    /// </summary>
    /// <returns>JSON Array</returns>
    private static System.Data.DataTable getToDoItems() {
        string sqlConnectionString = System.Configuration.ConfigurationManager.ConnectionStrings["BigVoltage"].ToString();
        
        System.Data.DataTable dtItems = new System.Data.DataTable();
        dtItems.Columns.Add("index", Type.GetType("System.Int32"));
        dtItems.Columns.Add("value", Type.GetType("System.String"));
        dtItems.Columns.Add("done", Type.GetType("System.Boolean"));

        using (System.Data.SqlClient.SqlConnection _sqlConn = new System.Data.SqlClient.SqlConnection(sqlConnectionString)) {
            //Open connection
            _sqlConn.Open();
            //Define command
            System.Data.SqlClient.SqlCommand _sqlCommand = new System.Data.SqlClient.SqlCommand("[dbo].[GetToDoListItems]", _sqlConn);
            _sqlCommand.CommandType = System.Data.CommandType.StoredProcedure;
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