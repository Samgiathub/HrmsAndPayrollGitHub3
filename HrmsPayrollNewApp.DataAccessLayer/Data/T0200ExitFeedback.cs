using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200ExitFeedback
{
    public decimal ExitFeedbackId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? ExitId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? QuestionId { get; set; }

    public decimal AnswerRate { get; set; }

    public string? Comments { get; set; }

    public string? FeedStatus { get; set; }

    public byte IsDraft { get; set; }
}
