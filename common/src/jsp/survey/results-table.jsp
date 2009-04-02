<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<table id="test-results-table" class="shaded" cellspacing="0">
	<tr>
		<th>Research Group&nbsp;</th>
		<th>Student Name&nbsp;</th>
		<th>Correct/Total&nbsp;</th>
		<th>Answers&nbsp;</th>
	</tr>
	
	<c:forEach items="${results}" var="groups">
		<!-- First level is the research group -->
		<% pageContext.setAttribute("first", true); %>
		<!--  <tr>
			<td colspan="4"><hr noshade size="1"></td>
		</tr> -->
		<c:forEach items="${groups.value}" var="result">
			<tr>
				<c:choose>
					<c:when test="${first}">
						<%	
							pageContext.setAttribute("rowskip", ((Map) ((Map.Entry) pageContext.getAttribute("groups")).getValue()).size());
							pageContext.setAttribute("first", false); 
							%>
						<td rowspan="${rowskip}" style="border-top: 1px solid Grey; border-right: 1px solid Grey">${groups.key.name}</td>
						<td style="border-top: 1px solid Grey">${result.key.name}</td>
					</c:when>
					<c:otherwise>
						<td style="border-top: 1px solid Grey">${result.key.name}</td>
					</c:otherwise>
				</c:choose>
				<%
					List l = (List) ((Map.Entry) pageContext.getAttribute("result")).getValue();
					
					if (l.isEmpty()) {
					    request.setAttribute("correct", "Test not taken");
					}
					else {
					    int correct = 0;
						Iterator i = l.iterator();
						while (i.hasNext()) {
						    ElabSurveyQuestion q = (ElabSurveyQuestion) i.next();
					    	if (q.getCorrectAnswerGiven()) {
					    	    correct++;
					    	}
						}
						request.setAttribute("correct", correct + "/" + l.size());
					}
				%>

						<td style="border-top: 1px solid Grey">${correct}</td>
						<td style="border-top: 1px solid Grey">

					<c:choose>
						<c:when test="${param.color == 'no'}">
							<c:forEach items="${result.value}" var="question">
								<c:choose>
									<c:when test="${question.correctAnswerGiven}">
										<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.id}">Q${question.number}+</a>
									</c:when>
									<c:otherwise>
										<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.id}">Q${question.number}-</a>
									</c:otherwise>
								</c:choose>
							</c:forEach>
						</c:when>
						<c:otherwise>
							<c:forEach items="${result.value}" var="question">
								<c:choose>
									<c:when test="${question.correctAnswerGiven}">
										<span style="background-color: #60ff40;">
											<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.id}">Q${question.number}</a>
										</span>
									</c:when>
									<c:otherwise>
										<span style="background-color: #ffa060;">
											<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.id}">Q${question.number}</a>
										</span>
									</c:otherwise>
								</c:choose>
								&nbsp;
							</c:forEach>
						</c:otherwise>
					</c:choose>
				</td>
			</tr>
		</c:forEach>
	</c:forEach>

			
</table>
