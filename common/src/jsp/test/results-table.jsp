<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<table id="test-results-table" class="shaded">
	<tr>
		<th>Student Name</th>
		<th>Correct/Total</th>
		<th>Answers</th>
	</tr>
	<c:forEach items="${results}" var="result">
		<tr>
			<td>${result.key.name}</td>
			<%
				List l = (List) ((Map.Entry) pageContext.getAttribute("result")).getValue();
				
				if (l.isEmpty()) {
				    request.setAttribute("correct", "Test not taken");
				}
				else {
				    int correct = 0;
					Iterator i = l.iterator();
					while (i.hasNext()) {
					    ElabTestQuestion q = (ElabTestQuestion) i.next();
				    	if (q.isCorrectAnswerGiven()) {
				    	    correct++;
				    	}
					}
					request.setAttribute("correct", correct + "/" + l.size());
				}
			%>
			<td>${correct}</td>
			<td>
				<c:choose>
					<c:when test="${param.color == 'no'}">
						<c:forEach items="${result.value}" var="question">
							<c:choose>
								<c:when test="${question.correctAnswerGiven}">
									<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.index}">Q${question.id}+</a>
								</c:when>
								<c:otherwise>
									<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.index}">Q${question.id}-</a>
								</c:otherwise>
							</c:choose>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<c:forEach items="${result.value}" var="question">
							<c:choose>
								<c:when test="${question.correctAnswerGiven}">
									<span style="background-color: #60ff40;">
										<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.index}">Q${question.id}</a>
									</span>
								</c:when>
								<c:otherwise>
									<span style="background-color: #ffa060;">
										<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.index}">Q${question.id}</a>
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
</table>
