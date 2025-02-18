using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052HrmsEmpSelfAppraisal
{
    public decimal EsaId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal InitiateId { get; set; }

    public decimal SapparisalId { get; set; }

    public decimal EmpWeightage { get; set; }

    public decimal EmpRating { get; set; }

    public decimal FinalEmpScore { get; set; }

    public decimal? RmWeightage { get; set; }

    public decimal? RmRating { get; set; }

    public decimal? FinalRmScore { get; set; }

    public string? RmComments { get; set; }

    public decimal? HodWeightage { get; set; }

    public decimal? HodRating { get; set; }

    public decimal? FinalHodScore { get; set; }

    public string? HodComments { get; set; }

    public decimal? GhWeightage { get; set; }

    public decimal? GhRating { get; set; }

    public decimal? FinalGhScore { get; set; }

    public string? GhComments { get; set; }
}
