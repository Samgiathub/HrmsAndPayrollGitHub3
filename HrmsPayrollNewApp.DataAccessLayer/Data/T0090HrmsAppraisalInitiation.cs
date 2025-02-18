using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAppraisalInitiation
{
    public decimal ApprIntId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LoginId { get; set; }

    public int? InvokeEmp { get; set; }

    public int? InvokeSuperior { get; set; }

    public int? InvokeTeam { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal Status { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0090HrmsAppraisalInitiationDetail> T0090HrmsAppraisalInitiationDetails { get; set; } = new List<T0090HrmsAppraisalInitiationDetail>();

    public virtual ICollection<T0090HrmsFinalScore> T0090HrmsFinalScores { get; set; } = new List<T0090HrmsFinalScore>();
}
