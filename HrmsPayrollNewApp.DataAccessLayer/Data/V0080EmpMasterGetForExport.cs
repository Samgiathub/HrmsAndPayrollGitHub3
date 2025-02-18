using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080EmpMasterGetForExport
{
    public long? RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal EmpCode { get; set; }

    public decimal? EmpPunchCardNo { get; set; }

    public string? EmpName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string EmpSecondName { get; set; } = null!;

    public string EmpLastName { get; set; } = null!;

    public string? Gfather { get; set; }

    public string? EmpBdate { get; set; }

    public DateTime EmpJdate { get; set; }

    public DateTime? ConfirmDate { get; set; }

    public string EmpJobDesc { get; set; } = null!;

    public string? EmpBloodGroup { get; set; }

    public string? EmpAdd1 { get; set; }

    public string? EmpCity { get; set; }

    public string? EmpTaluka { get; set; }

    public string? EmpDist { get; set; }

    public string? EmpPinCode { get; set; }

    public string? EmpPhone { get; set; }

    public string? EmpMobile { get; set; }

    public string? EmpCadd1 { get; set; }

    public string? EmpCcity { get; set; }

    public string? EmpCtaluka { get; set; }

    public string? EmpCdist { get; set; }

    public string? EmpCpinCode { get; set; }

    public string? EmpCphone { get; set; }

    public string? EmpCmobile { get; set; }

    public decimal? MgrCode { get; set; }

    public string? EmpRefCode { get; set; }

    public string? EmpRefName { get; set; }

    public string DeptCode { get; set; } = null!;

    public string EmpLeft { get; set; } = null!;

    public byte? Ph { get; set; }

    public string? VehicleNo { get; set; }

    public string? Gender { get; set; }

    public string? MaritalStatus { get; set; }

    public string? SamExtNo { get; set; }

    public DateTime? EmpLeaveDate { get; set; }

    public string? EmpLeaveReason { get; set; }

    public string? Unit { get; set; }

    public string? ManagementNote { get; set; }

    public string DoNotAllow { get; set; } = null!;

    public string? Esicno { get; set; }

    public string? Epfno { get; set; }

    public string? DesigCode { get; set; }

    public string? SalaryInBank { get; set; }

    public string? BankCode { get; set; }

    public string? BankName { get; set; }

    public string? IncBankAcNo { get; set; }

    public string? Pan { get; set; }

    public string? MailId { get; set; }

    public string? CompanyMailId { get; set; }

    public string? EpfuniversalId { get; set; }

    public string? RationCardType { get; set; }

    public string? RationCardNo { get; set; }

    public string? NameInBankForEpf { get; set; }

    public byte? IsEmpFnf { get; set; }

    public string WageCalculationType { get; set; } = null!;
}
