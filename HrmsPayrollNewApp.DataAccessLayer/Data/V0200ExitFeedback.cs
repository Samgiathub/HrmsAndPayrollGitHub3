using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0200ExitFeedback
{
    public decimal ExitFeedbackId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? ExitId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? QuestionId { get; set; }

    public decimal AnswerRate { get; set; }

    public string? Comments { get; set; }

    public decimal? Expr1 { get; set; }

    public string? Question { get; set; }

    public string? Description { get; set; }

    public byte? IsActive { get; set; }
}
