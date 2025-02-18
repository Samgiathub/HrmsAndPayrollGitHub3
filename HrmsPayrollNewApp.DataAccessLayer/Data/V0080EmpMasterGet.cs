using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080EmpMasterGet
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal ShiftId { get; set; }

    public decimal? BankId { get; set; }

    public decimal EmpCode { get; set; }

    public string? Initial { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string EmpSecondName { get; set; } = null!;

    public string EmpLastName { get; set; } = null!;

    public decimal? CurrId { get; set; }

    public DateTime DateOfJoin { get; set; }

    public string? SsnNo { get; set; }

    public string? SinNo { get; set; }

    public string? DrLicNo { get; set; }

    public string? PanNo { get; set; }

    public string? MaritalStatus { get; set; }

    public string? Gender { get; set; }

    public string? Nationality { get; set; }

    public decimal? LocId { get; set; }

    public string? Street1 { get; set; }

    public string? City { get; set; }

    public string? State { get; set; }

    public string? ZipCode { get; set; }

    public string? HomeTelNo { get; set; }

    public string? MobileNo { get; set; }

    public string? WorkTelNo { get; set; }

    public string? WorkEmail { get; set; }

    public string? OtherEmail { get; set; }

    public decimal? BasicSalary { get; set; }

    public string? ImageName { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpLeft { get; set; }

    public DateTime? EmpLeftDate { get; set; }

    public decimal? IncrementId { get; set; }

    public string? PresentStreet { get; set; }

    public string? PresentCity { get; set; }

    public string? PresentState { get; set; }

    public string? PresentPostBox { get; set; }

    public string? DateOfBirth { get; set; }

    public string? DrLicExDate { get; set; }

    public string LoginName { get; set; } = null!;

    public string LoginPassword { get; set; } = null!;

    public decimal LoginId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? AlphaCode { get; set; }

    public string? OldRefNo { get; set; }

    public string? UanNo { get; set; }
}
