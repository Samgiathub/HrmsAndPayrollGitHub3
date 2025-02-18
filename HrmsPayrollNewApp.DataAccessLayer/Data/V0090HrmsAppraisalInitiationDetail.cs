using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsAppraisalInitiationDetail
{
    public decimal? ApprIntId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? LoginId { get; set; }

    public int? InvokeEmp { get; set; }

    public int? InvokeSuperior { get; set; }

    public int? InvokeTeam { get; set; }

    public decimal? CmpId { get; set; }

    public decimal ApprDetailId { get; set; }

    public decimal EmpId { get; set; }

    public int? IsEmpSubmit { get; set; }

    public int? IsSupSubmit { get; set; }

    public int IsAccept { get; set; }

    public DateTime? EmpSubmitDate { get; set; }

    public DateTime? SupSubmitDate { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public decimal? CatId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? BranchId { get; set; }

    public string? BranchName { get; set; }

    public int? IsTeamSubmit { get; set; }

    public DateTime? TeamSubmitDate { get; set; }

    public decimal? InspectionStatus { get; set; }
}
