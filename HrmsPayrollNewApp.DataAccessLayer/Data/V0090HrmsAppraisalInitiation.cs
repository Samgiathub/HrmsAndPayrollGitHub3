using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsAppraisalInitiation
{
    public string? LoginName { get; set; }

    public decimal ApprIntId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LoginId { get; set; }

    public int? InvokeEmp { get; set; }

    public int? InvokeSuperior { get; set; }

    public int? InvokeTeam { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal Status { get; set; }
}
