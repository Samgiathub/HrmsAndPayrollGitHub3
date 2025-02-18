using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsAppraisal
{
    public decimal ApprIntId { get; set; }

    public decimal EmpId { get; set; }

    public decimal ApprDetailId { get; set; }

    public int? IsEmpSubmit { get; set; }

    public int? IsSupSubmit { get; set; }

    public int IsAccept { get; set; }

    public DateTime? EmpSubmitDate { get; set; }

    public DateTime? SupSubmitDate { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public string? EmpFullName { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public DateTime? TeamSubmitDate { get; set; }

    public int? IsTeamSubmit { get; set; }
}
