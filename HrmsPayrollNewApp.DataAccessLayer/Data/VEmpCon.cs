using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class VEmpCon
{
    public decimal? ShiftId { get; set; }

    public DateTime? JoinDate { get; set; }

    public DateTime? LeftDate { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? BankId { get; set; }

    public decimal? CurrId { get; set; }

    public DateTime IncrementEffectiveDate { get; set; }

    public decimal? EmpCode { get; set; }

    public string? Initial { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpSecondName { get; set; }

    public string? EmpLastName { get; set; }

    public DateTime? DateOfBirth { get; set; }

    public string? Gender { get; set; }

    public decimal IncrementId { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public decimal? SalDateId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SubBranchId { get; set; }

    public string? EmpLeft { get; set; }

    public decimal? CenterId { get; set; }

    public decimal? BandId { get; set; }

    public string? AlphaEmpCode { get; set; }
}
