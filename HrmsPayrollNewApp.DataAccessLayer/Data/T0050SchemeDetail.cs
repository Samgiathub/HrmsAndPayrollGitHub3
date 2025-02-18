using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050SchemeDetail
{
    public decimal SchemeDetailId { get; set; }

    public decimal SchemeId { get; set; }

    public decimal CmpId { get; set; }

    public string Leave { get; set; } = null!;

    public decimal? RCmpId { get; set; }

    public decimal? RDesgId { get; set; }

    public byte IsRm { get; set; }

    public byte IsBm { get; set; }

    public decimal? AppEmpId { get; set; }

    public decimal? LeaveDays { get; set; }

    public byte IsFwdLeaveRej { get; set; }

    public byte RptLevel { get; set; }

    public DateTime TimeStamp { get; set; }

    public byte NotMandatory { get; set; }

    public byte ApprovalOverlimitTravelSettlmnt { get; set; }

    public byte IsHod { get; set; }

    public byte IsHr { get; set; }

    public byte IsPrm { get; set; }

    public byte IsRmtoRm { get; set; }

    public byte IsIntimation { get; set; }

    public decimal? DynHierId { get; set; }

    public byte IsIt { get; set; }

    public byte IsAccount { get; set; }

    public byte IsTravelHelpDesk { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040SchemeMaster Scheme { get; set; } = null!;
}
