using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120TravelApproval
{
    public decimal TravelApprovalId { get; set; }

    public decimal? TravelApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public string? ApprovalComments { get; set; }

    public decimal LoginId { get; set; }

    public DateTime CreateDate { get; set; }

    public DateTime? ModifyDate { get; set; }

    public int IsImport { get; set; }

    public decimal Total { get; set; }

    public byte ChkAdv { get; set; }

    public byte ChkAgenda { get; set; }

    public string? TourAgenda { get; set; }

    public string? ImpBusinessAppoint { get; set; }

    public string? KraTour { get; set; }

    public string? AttachedDocFile { get; set; }

    public string? ApprovedStatusHelpDesk { get; set; }

    public string? CommentsHelpDesk { get; set; }

    public string? ApprovedAccountAdvanceDesk { get; set; }

    public string? ApprovedAccountComments { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }

    public virtual ICollection<T0130TravelApprovalAdvdetail> T0130TravelApprovalAdvdetails { get; set; } = new List<T0130TravelApprovalAdvdetail>();

    public virtual ICollection<T0130TravelApprovalDetail> T0130TravelApprovalDetails { get; set; } = new List<T0130TravelApprovalDetail>();

    public virtual ICollection<T0130TravelHelpDesk> T0130TravelHelpDesks { get; set; } = new List<T0130TravelHelpDesk>();

    public virtual ICollection<T0140TravelSettlementGroupEmp> T0140TravelSettlementGroupEmps { get; set; } = new List<T0140TravelSettlementGroupEmp>();

    public virtual T0100TravelApplication? TravelApplication { get; set; }
}
