using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0400EmployeeComment
{
    public decimal CommentId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpIdComment { get; set; }

    public DateTime ForDate { get; set; }

    public decimal UCommentId { get; set; }

    public DateTime CommentDate { get; set; }

    public string Comment { get; set; } = null!;

    public string CommentStatus { get; set; } = null!;

    public decimal NotificationFlag { get; set; }

    public decimal ReplyCommentId { get; set; }
}
