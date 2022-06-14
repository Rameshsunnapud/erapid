<html>
	<head>
		<title>Order Write-up sheet Mailing</title>
		<link rel='stylesheet' href='../../../style1.css' type='text/css'/>
	</head>
	<body>
		<h1>EMail Notification::</h1>
		<%@ page language="java" import="javax.mail.*" import="java.util.*" import="java.math.*" import="java.sql.*" import="javax.mail.internet.*" import="javax.activation.*" import="java.net.*" import="java.text.*" errorPage="error.jsp" %>
		<%@ include file="../../../db_con.jsp"%>
		<%
		HttpSession UserSession1 = request.getSession();
		String name=UserSession1.getAttribute("username").toString();
		String product_id="";
		String order_no = request.getParameter("order_no");
		String sections = request.getParameter("sections");
		String rep_no = request.getParameter("rep_no");
		String from = request.getParameter("from") ;
		if(!from.trim().endsWith("@c-sgroup.com")){
			from="no_reply_ows@c-sgroup.com";
		}
		String to = request.getParameter("to");
		String cc = request.getParameter("cc");
		String rep_message = request.getParameter("message");
		String rep_info="";

		try{
			ResultSet rs1=stmt.executeQuery("select * from cs_reps where rep_no='"+rep_no+"'");
			if(rs1 != null){
				while(rs1.next()){
					rep_info=rs1.getString("rep_account")+"\r\n\n ";
					rep_info=rep_info+rs1.getString("telephone")+"\r\n\n ";
					rep_info=rep_info+rs1.getString("email");

				}
			}
			rs1.close();
			ResultSet rs_project = stmt.executeQuery("SELECT product_id FROM cs_project where Order_no like '"+order_no+"' ");
			if (rs_project !=null) {
				while (rs_project.next()) {
					product_id= rs_project.getString("product_id");
				}
			}
			rs_project.close();
			//String host ="lebhq-notes.c-sgroup.com";
			String host ="LEBHQ-SMTP01.c-sgroup.com";
			String subject = "Construction Specialties Order Sheet for \'"+order_no+"\' Project";
			String message = "";
			message = message+"Attached Below is the Construction Specialties Order Write-up sheet for Erapid order::"+order_no+".";
			//message = message+"\r\nProject:: \'"+order_no+"\' ";
			//			message=message+"\r\n\n Contact Info: "+rep_info ;
			message=message+" \r\n\n "+rep_message+" \r\n\n";
			String localfile = "d:\\custom\\quotes\\images\\cs_logo.jpg";
			String attachName = "Order sheet -"+order_no+".html";
			String url="";
			String message_footer="\r\n";
			message_footer=message_footer+"\n\n\n[THIS MESSAGE WAS AUTOGENERATED BY CONSTRUCTION SPECIALTIES QUOTE SYSTEM]";
			message_footer=message_footer+"\n====================";
			message_footer=message_footer+"\nThis email message and any files transmitted with it is for the sole ";
			message_footer=message_footer+"\nuse of the intended recipient(s) and may contain confidential and privileged ";
			message_footer=message_footer+"\ninformation. Any unauthorized review, use, disclosure or distribution of this";
			message_footer=message_footer+"\nemail content is prohibited. If you are not the intended recipient, please";
			message_footer=message_footer+"\ndestroy all paper and electronic copies of the original message.";
			message_footer=message_footer+"\n====================";
			url= ""+application.getInitParameter("HOST")+"/erapid/us/orders/ows/order_sheet.jsp?sections="+sections+"&rep_no="+rep_no.trim()+"&orderNo="+order_no;
			Properties prop =System.getProperties();
			prop.put("mail.smtp.host",host);
			Session ses1  = Session.getDefaultInstance(prop,null);
			MimeMessage msg = new MimeMessage(ses1);
			msg.addFrom(new InternetAddress().parse(from));
			msg.addRecipients(Message.RecipientType.TO,new InternetAddress().parse(to));
			msg.addRecipients(Message.RecipientType.CC,new InternetAddress().parse(cc));
			msg.setSubject(subject);
			// Create the message part
			BodyPart messageBodyPart = new MimeBodyPart();
			// Fill the message
			messageBodyPart.setText(message);
			Multipart multipart = new MimeMultipart();
			multipart.addBodyPart(messageBodyPart);
			// Part two is attachment
			messageBodyPart = new MimeBodyPart();
			DataSource source = new URLDataSource(new URL("http://"+url));
			messageBodyPart.setDataHandler(new DataHandler(source));
			messageBodyPart.setFileName(attachName);
			multipart.addBodyPart(messageBodyPart);
			msg.setContent(multipart);
			//adding the footer
			messageBodyPart = new MimeBodyPart();
			messageBodyPart.setText(message_footer);
			multipart.addBodyPart(messageBodyPart);
			Transport.send(msg);
			out.println(" An Email has been successfully delivered<br> to following recipients:<br> "+to+"<br>"+cc);


			String insert ="INSERT INTO cs_ows_transfer_email_log([order_no],[time_sent],[rep_no],[product_id],[from_email],[to_email],[user_id])VALUES(?,?,?,?,?,?,?) ";
			PreparedStatement update_mat_shop_orders = myConn.prepareStatement(insert);
			update_mat_shop_orders.setString(1,order_no);
			update_mat_shop_orders.setTimestamp(2,new java.sql.Timestamp(Calendar.getInstance().getTime().getTime()));
			update_mat_shop_orders.setString(3,rep_no);
			update_mat_shop_orders.setString(4,product_id);
			update_mat_shop_orders.setString(5,from);
			update_mat_shop_orders.setString(6,to);
			update_mat_shop_orders.setString(7,name);
			int rocount = update_mat_shop_orders.executeUpdate();
			update_mat_shop_orders.close();
		}
		catch(javax.mail.internet.AddressException ae){
			ae.printStackTrace();
			//out.println(ae+"::1<BR>");
			String insert ="INSERT INTO cs_ows_transfer_email_log([order_no],[time_sent],[rep_no],[product_id],[from_email],[to_email],[user_id])VALUES(?,?,?,?,?,?,?) ";

			PreparedStatement update_mat_shop_orders = myConn.prepareStatement(insert);
			update_mat_shop_orders.setString(1,order_no);
			update_mat_shop_orders.setTimestamp(2,new java.sql.Timestamp(Calendar.getInstance().getTime().getTime()));
			update_mat_shop_orders.setString(3,rep_no);
			update_mat_shop_orders.setString(4,"ERROR1");
			update_mat_shop_orders.setString(5,from);
			update_mat_shop_orders.setString(6,to);
			update_mat_shop_orders.setString(7,name);
			int rocount = update_mat_shop_orders.executeUpdate();
			update_mat_shop_orders.close();
		}
		catch(javax.mail.MessagingException me){
			me.printStackTrace();
			//out.println(me+"::2<BR>");
			String insert ="INSERT INTO cs_ows_transfer_email_log([order_no],[time_sent],[rep_no],[product_id],[from_email],[to_email],[user_id])VALUES(?,?,?,?,?,?,?) ";

			PreparedStatement update_mat_shop_orders = myConn.prepareStatement(insert);
			update_mat_shop_orders.setString(1,order_no);
			update_mat_shop_orders.setTimestamp(2,new java.sql.Timestamp(Calendar.getInstance().getTime().getTime()));
			update_mat_shop_orders.setString(3,rep_no);
			update_mat_shop_orders.setString(4,"ERROR2");
			update_mat_shop_orders.setString(5,from);
			update_mat_shop_orders.setString(6,to);
			update_mat_shop_orders.setString(7,name);
			int rocount = update_mat_shop_orders.executeUpdate();
			update_mat_shop_orders.close();
		}
		catch(Exception e){
			//out.println(e+"::3");
			String insert ="INSERT INTO cs_ows_transfer_email_log([order_no],[time_sent],[rep_no],[product_id],[from_email],[to_email],[user_id])VALUES(?,?,?,?,?,?,?) ";

			PreparedStatement update_mat_shop_orders = myConn.prepareStatement(insert);
			update_mat_shop_orders.setString(1,order_no);
			update_mat_shop_orders.setTimestamp(2,new java.sql.Timestamp(Calendar.getInstance().getTime().getTime()));
			update_mat_shop_orders.setString(3,rep_no);
			update_mat_shop_orders.setString(4,"ERROR3");
			update_mat_shop_orders.setString(5,from);
			update_mat_shop_orders.setString(6,to);
			update_mat_shop_orders.setString(7,name);
			int rocount = update_mat_shop_orders.executeUpdate();
			update_mat_shop_orders.close();
		}
		stmt.close();
		myConn.close();
		%>
	</body>
</html>