using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040BankMaster
{
    public decimal BankId { get; set; }

    public decimal CmpId { get; set; }

    public string BankCode { get; set; } = null!;

    public string BankName { get; set; } = null!;

    public string BankAcNo { get; set; } = null!;

    public string BankAddress { get; set; } = null!;

    public string BankBranchName { get; set; } = null!;

    public string BankCity { get; set; } = null!;

    public string IsDefault { get; set; } = null!;

    public string? BankBsrCode { get; set; }

    public string? ClientCode { get; set; }

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinals { get; set; } = new List<T0060ResumeFinal>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0090HrmsResumeBank> T0090HrmsResumeBanks { get; set; } = new List<T0090HrmsResumeBank>();

    public virtual ICollection<T0120LoanApproval> T0120LoanApprovals { get; set; } = new List<T0120LoanApproval>();

    public virtual ICollection<T0220EsicChallanSett> T0220EsicChallanSetts { get; set; } = new List<T0220EsicChallanSett>();

    public virtual ICollection<T0220EsicChallan> T0220EsicChallans { get; set; } = new List<T0220EsicChallan>();

    public virtual ICollection<T0220PfChallanSett> T0220PfChallanSetts { get; set; } = new List<T0220PfChallanSett>();
}
