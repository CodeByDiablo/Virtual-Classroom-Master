<%@ page language="java" import="java.sql.*"%>
<%@ include file="db.jspf" %>

    <%

	String c[]= request.getParameterValues("ad");

	try
	{
		// establish the connection with the database
		Connection con = Db.getConnection();

		// create a SQL statement
		Statement stmt = con.createStatement();

		// if delete request is made
		if(request.getParameter("reject") != null)
		{
			for(String s:c)
			{
				String qy = "delete from student where roll_no ='" + s + "'";
				stmt.executeUpdate(qy);
			}
		}
		// else if accept request is made
		else if(request.getParameter("accept") != null)
		{
			for(String s:c)
			{
				String qy = "update student set is_approved = 1 where roll_no ='" + s + "'";
				stmt.executeUpdate(qy);
			}
		}
	}
	catch(Exception e)
	{
		out.println(e.getMessage());
	}
	response.sendRedirect("admin_student_requests.jsp");				// redirect to requsts' page
%>