using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsAppraisalEmpPerformanceSummary
{
    public decimal PsId { get; set; }

    public decimal PsCmpId { get; set; }

    public string? PsEmployeeComment { get; set; }

    public string? PsSupervisorComment { get; set; }

    public string? CpEmployeeComment { get; set; }

    public string? CpSupervisorComment { get; set; }

    public decimal? FkRating { get; set; }

    public decimal? FkEmployeeId { get; set; }

    public decimal? FkSupervisorId { get; set; }

    public byte? EmployeeSignOff { get; set; }

    public DateTime? EmployeeSignOffDate { get; set; }

    public byte? SupervisorSignOff { get; set; }

    public DateTime? SupervisorSignOffDate { get; set; }

    public DateTime? PsStartDate { get; set; }

    public DateTime? PsEndDate { get; set; }

    public decimal PsYear { get; set; }

    public decimal PsCreatedBy { get; set; }

    public DateTime PsCreatedDate { get; set; }

    public decimal? PsModifyBy { get; set; }

    public DateTime? PsModifyDate { get; set; }

    public string? Rating { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? SupFullName { get; set; }

    public string? AlphaSupCode { get; set; }
}
