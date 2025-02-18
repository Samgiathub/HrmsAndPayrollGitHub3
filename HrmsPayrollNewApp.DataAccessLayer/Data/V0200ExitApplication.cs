using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0200ExitApplication
{
    public decimal ExitId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? ResignationDate { get; set; }

    public DateTime LastDate { get; set; }

    public decimal? Reason { get; set; }

    public string? Comments { get; set; }

    public string Status { get; set; } = null!;

    public decimal? IsRehirable { get; set; }

    public decimal? SEmpId { get; set; }

    public string? Feedback { get; set; }

    public string? SupAck { get; set; }

    public DateTime? InterviewDate { get; set; }

    public string? InterviewTime { get; set; }

    public string IsProcess { get; set; } = null!;

    public decimal QuestId { get; set; }

    public string? Question { get; set; }

    public decimal QuestionType { get; set; }

    public string? QuestionOptions { get; set; }

    public decimal InterviewId { get; set; }

    public decimal SortingNo { get; set; }

    public string? StrDesigId { get; set; }

    public byte AutoAssign { get; set; }
}
