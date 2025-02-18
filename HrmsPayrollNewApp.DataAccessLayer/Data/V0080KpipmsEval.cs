using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080KpipmsEval
{
    public decimal KpipmsId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public int? KpipmsType { get; set; }

    public string? KpipmsName { get; set; }

    public decimal? KpipmsFinancialYr { get; set; }

    public int? KpipmsStatus { get; set; }

    public decimal? KpipmsFinalRating { get; set; }

    public int? KpipmsEmProcessFair { get; set; }

    public int? KpipmsEmpAgree { get; set; }

    public string? KpipmsEmpComments { get; set; }

    public int? KpipmsProcessFairSup { get; set; }

    public int? KpipmsSupAgree { get; set; }

    public string? KpipmsSupComments { get; set; }

    public string? KpipmsEmpEarlyComment { get; set; }

    public string? KpipmsSupEarlyComment { get; set; }

    public DateTime? KpimpsStartedOn { get; set; }

    public string? KpipmsEarlyComment { get; set; }

    public DateTime? KpimpsEmpAppOn { get; set; }

    public DateTime? KpimpsSupAppOn { get; set; }

    public DateTime? KpipmsFinalApproved { get; set; }

    public decimal? FinalScore { get; set; }

    public DateTime? SignOffEmpDate { get; set; }

    public DateTime? SignOffSupDate { get; set; }

    public int? FinalClose { get; set; }

    public DateTime? FinalClosedOn { get; set; }

    public decimal? FinalClosedBy { get; set; }

    public string? FinalClosingComment { get; set; }

    public string? FinalTraining { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? KpipmsManagerScore { get; set; }
}
