using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040CollectionMaster
{
    public decimal CollectionId { get; set; }

    public string? CollectionMonth { get; set; }

    public decimal? CollectionYear { get; set; }

    public decimal? ProjectId { get; set; }

    public string? ServiceType { get; set; }

    public string? ContractType { get; set; }

    public decimal? PracticeCollection { get; set; }

    public decimal? ChargesPer { get; set; }

    public decimal? FedoraCharges { get; set; }

    public decimal? ExchangeRate { get; set; }

    public decimal? TotalFedoraCharges { get; set; }

    public string? OtherRemarks { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ManagerId { get; set; }

    public virtual T0040TsProjectMaster? Project { get; set; }
}
