using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsAppraisalStatusReport
{
    public decimal ApprIntId { get; set; }

    public decimal ApprDetailId { get; set; }

    public DateTime ForDate { get; set; }

    public int? InvokeEmp { get; set; }

    public int? InvokeSuperior { get; set; }

    public int? InvokeTeam { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int IsAccept { get; set; }

    public int? IsEmpSubmit { get; set; }

    public int? IsSupSubmit { get; set; }

    public int? IsTeamSubmit { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public decimal? IncrementId { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public decimal? InspectionStatus { get; set; }

    public decimal? EmpStatus { get; set; }
}
